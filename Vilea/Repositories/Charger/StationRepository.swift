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

    enum State {
        case `default`
        case loading
        case failed
        case loaded([Station])
    }

    @Published private(set) var dataState: State = .default
    @Published private(set) var stationStates: [StationState] = []

    private let remote = StationRemoteRepository()
    private let local = StationLocalRepository()

    func fetchStations() {
        Task {
            dataState = .loading
            
            let stations = await local.stations()
            if stations.isEmpty {
                do {
                    let staticData = try await remote.fetchStaticData()
                    OSLog.general.log("Fetching static station data has finished")
                    
                    let evseRootData: EVSERoot = try staticData.decoded()
                    let staticStations = await local.storeStaticStationData(evseRootData)
                    dataState = .loaded(staticStations)
                } catch {
                    OSLog.general.error("Failure occured during fetching stations: \(error.localizedDescription)")
                    dataState = .failed
                }
            } else {
                OSLog.general.log("Cached static station available: \(stations.count) records.")
                dataState = .loaded(stations)
            }

            // In any case, fetch availability data
            do {
                let dynamicData = try await remote.fetchDynamicData()
                OSLog.general.log("Fetching dynamic station data has finished")
                
                let evseStatuses: EVSEStatusesRoot = try dynamicData.decoded()
                self.stationStates = await local.storeDynamicStationData(evseStatuses)
            } catch {
                OSLog.general.error("Failure occured during fetching dynamic data: \(error.localizedDescription)")
            }
        }
    }

    // For the case user is offline
    func loadCachedDynamicData() {
        self.stationStates = local.stationStates()
    }
}
