//
//  Station+Extensions.swift
//  Vilea
//
//  Created by Konstantin Gonikman on 09.07.24.
//

import Foundation
import CoreLocation

extension Station {
    var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}
