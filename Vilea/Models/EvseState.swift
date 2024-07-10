//
//  EvseState.swift
//  Vilea
//
//  Created by Konstantin Gonikman on 10.07.24.
//

import UIKit

enum EvseAvailability: String {
    case unknown = "Unknown"
    case occupied = "Occupied"
    case outOfService = "OutOfService"
    case available = "Available"
}

extension EvseAvailability {
    var tintColor: UIColor {
        switch self {
        case .unknown:
            return .lightGray
        case .occupied:
            return .systemRed
        case .outOfService:
            return .darkGray
        case .available:
            return .systemGreen
        }
    }
}


struct EvseState {
    let evseId: String
    let availability: EvseAvailability
}
