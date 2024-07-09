//
//  EVSEStatusRecord.swift
//  Vilea
//
//  Created by Konstantin Gonikman on 10.07.24.
//

import Foundation

struct EVSEStatusRecord: Decodable {
    let stationId: String
    let status: String

    enum CodingKeys: String, CodingKey {
        case stationId = "EvseID"
        case status = "EVSEStatus"
    }
}
