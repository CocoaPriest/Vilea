//
//  StationAnnotation.swift
//  Vilea
//
//  Created by Konstantin Gonikman on 10.07.24.
//

import MapKit

// TODO: use UniqueStation as MKAnnotation
class StationAnnotation: NSObject, MKAnnotation {
    var title: String? {
        return uniqueStation.stationId
    }

    var subtitle: String? {
        var subtitleChunks = [String]()
        subtitleChunks.append("\(uniqueStation.maxPower)kW")

        if let lastUpdate = uniqueStation.lastUpdate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            let str = dateFormatter.string(from: lastUpdate)
            subtitleChunks.append("updated on:" + str)
        }

        return subtitleChunks.joined(separator: "; ")
    }

    let coordinate: CLLocationCoordinate2D
    let isAvailabile: Bool

    private let uniqueStation: UniqueStation

    init(uniqueStation: UniqueStation) {
        self.isAvailabile = uniqueStation.isAvailabile
        self.coordinate = uniqueStation.coordinate
        self.uniqueStation = uniqueStation
        super.init()
    }
}
