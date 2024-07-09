//
//  Station+Extensions.swift
//  Vilea
//
//  Created by Konstantin Gonikman on 09.07.24.
//

import Foundation
import CoreLocation

extension Station {
    var location: CLLocation? {
        guard latitude != 0 && longitude != 0 else {
            return nil
        }

        return CLLocation(latitude: latitude, longitude: longitude)
    }
}
