//
//  GeoCoordinates.swift
//  Vilea
//
//  Created by Konstantin Gonikman on 09.07.24.
//

import Foundation
import CoreLocation
import OSLog

struct GeoCoordinates: Decodable {
    let google: String

    enum CodingKeys: String, CodingKey {
        case google = "Google"
    }

    var locationCoordinate2D: CLLocationCoordinate2D? {
        let coords = google.split(separator: " ")

        guard coords.count == 2,
              let latitude = Double(coords[0]),
              let longitude = Double(coords[1]) else {
            OSLog.general.error("Can't parse CLLocationCoordinate2D: \(coords)")
            return nil
        }

        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
