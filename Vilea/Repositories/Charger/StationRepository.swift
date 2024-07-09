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

    private let remote = StationRemoteRepository()
    private let local = StationLocalRepository()

    func fetchStaticData() {
        dataState = .loading

        let staticStations = local.staticStations()
        if staticStations.isEmpty {
            Task {
                do {
                    let data = try await remote.fetchStaticData()
                    OSLog.general.log("Fetching static station data has finished")

                    let evseRootData: EVSERoot = try data.decoded()
                    let staticStations = await local.storeStaticStationData(evseRootData)
                    dataState = .loaded(staticStations)
                } catch {
                    OSLog.general.error("Failure occured during fetching station api: \(error.localizedDescription)")
                    dataState = .failed
                }
            }
        } else {
            dataState = .loaded(staticStations)
        }
    }
}
