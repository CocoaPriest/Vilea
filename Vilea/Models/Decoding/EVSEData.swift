//
//  EVSEData.swift
//  Vilea
//
//  Created by Konstantin Gonikman on 09.07.24.
//

import Foundation

struct EVSEData: Decodable {
    let operatorID: String
    let operatorName: String
    let dataRecords: [EVSEDataRecord]

    enum CodingKeys: String, CodingKey {
        case operatorID = "OperatorID"
        case operatorName = "OperatorName"
        case dataRecords = "EVSEDataRecord"
    }
}
