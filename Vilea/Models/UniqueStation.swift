//
//  UniqueStation.swift
//  Vilea
//
//  Created by Konstantin Gonikman on 10.07.24.
//

import Foundation
import MapKit

class UniqueStation: NSObject {
    let stationId: String
    let maxPower: Int
    let coordinate: CLLocationCoordinate2D
    let lastUpdate: Date?
    let availability: EvseAvailability

    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(stationId)
        return hasher.finalize()
    }

    static func == (lhs: UniqueStation, rhs: UniqueStation) -> Bool {
        return lhs.stationId == rhs.stationId
    }

    init(stationId: String, maxPower: Int, coordinate: CLLocationCoordinate2D, lastUpdate: Date?, availability: EvseAvailability) {
        self.stationId = stationId
        self.maxPower = maxPower
        self.coordinate = coordinate
        self.lastUpdate = lastUpdate
        self.availability = availability
        super.init()
    }
}

extension UniqueStation: MKAnnotation {
    var title: String? {
        return stationId
    }

    var subtitle: String? {
        var subtitleChunks = [String]()
        subtitleChunks.append("\(maxPower)kW")

        if let lastUpdate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            let str = dateFormatter.string(from: lastUpdate)
            subtitleChunks.append("updated on:" + str)
        }

        return subtitleChunks.joined(separator: "; ")
    }
}
