//
//  StationRemoteRepository.swift
//  Vilea
//
//  Created by Konstantin Gonikman on 09.07.24.
//

import Foundation

class StationRemoteRepository {
    func fetchStaticData() async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: AppConfig.API.staticDataURL, delegate: nil)
        return data
    }

    func fetchDynamicData() async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: AppConfig.API.dynamicDataURL, delegate: nil)
        return data
    }
}
