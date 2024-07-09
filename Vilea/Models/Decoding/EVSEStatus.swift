//
//  EVSEStatus.swift
//  Vilea
//
//  Created by Konstantin Gonikman on 10.07.24.
//

import Foundation

struct EVSEStatus: Decodable {
    let operatorID: String
    let operatorName: String
    let statusRecords: [EVSEStatusRecord]

    enum CodingKeys: String, CodingKey {
        case operatorID = "OperatorID"
        case operatorName = "OperatorName"
        case statusRecords = "EVSEStatusRecord"
    }
}
