//
//  EVSEStatusRecord.swift
//  Vilea
//
//  Created by Konstantin Gonikman on 10.07.24.
//

import Foundation

struct EVSEStatusRecord: Decodable {
    let evseId: String
    let status: String

    enum CodingKeys: String, CodingKey {
        case evseId = "EvseID"
        case status = "EVSEStatus"
    }
}
