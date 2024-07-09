//
//  ChargerRepository.swift
//  Vilea
//
//  Created by Konstantin Gonikman on 09.07.24.
//

import Foundation
import Combine
import OSLog

class ChargerRepository {

    enum State {
        case `default`
        case loading
        case failed
        case loaded([Charger])
    }

    @Published private(set) var dataState: State = .default

    private let remote = ChargerRemoteRepository()
    private let local = ChargerLocalRepository()

    func fetchStaticData() {
        dataState = .loading

        if let staticChargers = local.staticChargers() {
            dataState = .loaded(staticChargers)
        } else {
            Task {
                do {
                    let data = try await remote.fetchStaticData()
                    OSLog.general.log("Fetching static charger data has finished")

                    let evseRootData: EVSERoot = try data.decoded()
                    let staticChargers = mapEVSEData(evseRootData)

                    local.storeStaticData(staticChargers)
                    dataState = .loaded(staticChargers)
                } catch {
                    OSLog.general.error("Failure occured during fetching charger api: \(error.localizedDescription)")
                    dataState = .failed
                }
            }
        }
    }

    private func mapEVSEData(_ root: EVSERoot) -> [Charger] {
        return []
    }
}
