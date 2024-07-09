//
//  EVSEStatusesRoot.swift
//  Vilea
//
//  Created by Konstantin Gonikman on 10.07.24.
//

import Foundation

struct EVSEStatusesRoot: Decodable {
    let statuses: [EVSEStatus]

    enum CodingKeys: String, CodingKey {
        case statuses = "EVSEStatuses"
    }
}
