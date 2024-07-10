//
//  EVSEDataRecord.swift
//  Vilea
//
//  Created by Konstantin Gonikman on 09.07.24.
//

import Foundation
import CoreLocation

struct EVSEDataRecord: Decodable {
    let stationId: String
    let evseId: String
    let lastUpdate: Date?
    let coordinates: CLLocationCoordinate2D?
    let facilities: [ChargingFacility]

    enum CodingKeys: String, CodingKey {
        case stationId = "ChargingStationId"
        case evseId = "EvseID"
        case lastUpdate
        case coordinates = "GeoCoordinates"
        case facilities = "ChargingFacilities"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        stationId = try container.decode(String.self, forKey: .stationId)
        evseId = try container.decode(String.self, forKey: .evseId)
        lastUpdate = try container.decodeIfPresent(Date.self, forKey: .lastUpdate)

        let gc = try container.decode(GeoCoordinates.self, forKey: .coordinates)
        coordinates = gc.locationCoordinate2D

        facilities = try container.decode([ChargingFacility].self, forKey: .facilities)
    }
}
