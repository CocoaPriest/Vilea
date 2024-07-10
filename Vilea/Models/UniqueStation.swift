//
//  UniqueStation.swift
//  Vilea
//
//  Created by Konstantin Gonikman on 10.07.24.
//

import Foundation
import CoreLocation

struct UniqueStation: Hashable {
    let stationId: String
    let maxPower: Int
    let coordinate: CLLocationCoordinate2D
    let lastUpdate: Date?
    let isAvailabile: Bool

    func hash(into hasher: inout Hasher) {
        hasher.combine(stationId)
    }

    static func == (lhs: UniqueStation, rhs: UniqueStation) -> Bool {
        return lhs.stationId == rhs.stationId
    }
}
