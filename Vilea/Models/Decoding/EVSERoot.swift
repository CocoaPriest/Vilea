//
//  EVSERoot.swift
//  Vilea
//
//  Created by Konstantin Gonikman on 09.07.24.
//

import Foundation

struct EVSERoot: Decodable {
    let evseData: [EVSEData]

    enum CodingKeys: String, CodingKey {
        case evseData = "EVSEData"
    }
}
