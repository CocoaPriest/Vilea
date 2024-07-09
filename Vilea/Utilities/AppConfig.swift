//
//  AppConfig.swift
//  Vilea
//
//  Created by Konstantin Gonikman on 09.07.24.
//

import Foundation

struct AppConfig {
    struct API {
        static let staticDataURL = URL(string: "https://data.geo.admin.ch/ch.bfe.ladestellen-elektromobilitaet/data/ch.bfe.ladestellen-elektromobilitaet.json")!
        static let dynamicDataURL = URL(string: "https://data.geo.admin.ch/ch.bfe.ladestellen-elektromobilitaet/status/ch.bfe.ladestellen-elektromobilitaet.json")!
    }
}
