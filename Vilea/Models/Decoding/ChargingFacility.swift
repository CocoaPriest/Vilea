//
//  ChargingFacility.swift
//  Vilea
//
//  Created by Konstantin Gonikman on 09.07.24.
//

import Foundation

struct ChargingFacility: Decodable {
    let power: Int

    enum CodingKeys: String, CodingKey {
        case power
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let powerInt = try? container.decode(Int.self, forKey: .power) {
            power = powerInt
        } else if let powerDouble = try? container.decode(Double.self, forKey: .power) {
            power = Int(powerDouble)
        } else if let powerString = try? container.decode(String.self, forKey: .power),
                  let powerDouble = Double(powerString) {
            power = Int(powerDouble)
        } else {
            power = 0
        }
    }
}
