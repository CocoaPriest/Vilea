//
//  ChargerRemoteRepository.swift
//  Vilea
//
//  Created by Konstantin Gonikman on 09.07.24.
//

import Foundation

class ChargerRemoteRepository {
    func fetchStaticData() async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: AppConfig.API.staticDataURL, delegate: nil)
        return data
    }
}
