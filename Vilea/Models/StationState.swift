//
//  StationState.swift
//  Vilea
//
//  Created by Konstantin Gonikman on 10.07.24.
//

import Foundation

enum StationAvailability: String {
    case unknown = "Unknown"
    case occupied = "Occupied"
    case outOfService = "OutOfService"
    case available = "Available"
}

struct StationState {
    let stationId: String
    let availability: StationAvailability
}
