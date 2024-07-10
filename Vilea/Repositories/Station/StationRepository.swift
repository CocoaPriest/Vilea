//
//  StationRepository.swift
//  Vilea
//
//  Created by Konstantin Gonikman on 09.07.24.
//

import Foundation
import Combine
import OSLog

class StationRepository {

    enum LoadState {
        case `default`
        case loading
        case failed
        case loaded(Set<UniqueStation>)
    }

    @Published private(set) var loadState: LoadState = .default

    private let remote = StationRemoteRepository()
    private let local = StationLocalRepository()

    func fetchStations() {
        Task { [weak self] in
            guard let self else { return }
            loadState = .loading
            
            var cachedStations = await local.stations()
            if cachedStations.isEmpty {
                do {
                    let staticData = try await remote.fetchStaticData()
                    OSLog.general.log("Fetching static station data has finished")
                    
                    let evseRootData: EVSERoot = try staticData.decoded()
                    cachedStations = await local.storeStaticStationData(evseRootData)
                } catch {
                    OSLog.general.error("Failure occured during fetching stations: \(error.localizedDescription)")
                    loadState = .failed
                }
            }

            // In any case, fetch availability data
            do {
                let dynamicData = try await remote.fetchDynamicData()
                OSLog.general.log("Fetching dynamic station data has finished")
                
                let evseStatusesRoot: EVSEStatusesRoot = try dynamicData.decoded()
                let evseStates = await local.storeDynamicStationData(evseStatusesRoot)
                updateDataState(cachedStations, evseStates: evseStates)
            } catch {
                OSLog.general.error("Failure occured during fetching dynamic data: \(error.localizedDescription)")
            }
        }
    }

    // For the case user is offline
    func loadCachedData() {
        Task { [weak self] in
            guard let self else { return }
            let cachedStations = await local.stations()
            guard !cachedStations.isEmpty else {
                return
            }

            let evseStates = await local.evseStates()
            updateDataState(cachedStations, evseStates: evseStates)
        }
    }

    // Combine stations to unique ones + set availability states and emit
    private func updateDataState(_ stations: [Station], evseStates: [EvseState]) {
        // Preprocess => perfomance
        var stationAvailability: [String: Bool] = [:]
        for state in evseStates {
            stationAvailability[state.evseId, default: false] = state.availability == .available
        }

        var groupedStations: [String: [Station]] = [:]
        for station in stations {
            groupedStations[station.stationId!, default: []].append(station)
        }

        // Process
        let uniqueStations = groupedStations.map { (stationId, evseItems) -> UniqueStation in
            let maxPower = evseItems.flatMap { evse -> [Int] in
                guard let powerSet = evse.power as? Set<Power> else { return [] }
                return powerSet.map { Int($0.val) }
            }.max() ?? 0

            let isAvailable = stationAvailability[stationId] ?? false

            return UniqueStation(stationId: stationId,
                                 maxPower: maxPower,
                                 coordinate: evseItems[0].location.coordinate,
                                 lastUpdate: evseItems[0].lastUpdate,
                                 isAvailabile: isAvailable)
        }

        loadState = .loaded(Set(uniqueStations))
    }
}
