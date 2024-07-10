//
//  EvseState.swift
//  Vilea
//
//  Created by Konstantin Gonikman on 10.07.24.
//

import Foundation

enum EvseAvailability: String {
    case unknown = "Unknown"
    case occupied = "Occupied"
    case outOfService = "OutOfService"
    case available = "Available"
}

struct EvseState {
    let evseId: String
    let availability: EvseAvailability
}
