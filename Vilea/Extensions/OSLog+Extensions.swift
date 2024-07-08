//
//  OSLog+Extensions.swift
//  Vilea
//
//  Created by Konstantin Gonikman on 08.07.24.
//

import Foundation
import os.log

public extension OSLog {
    private static let subsystem: String = Bundle.main.bundleIdentifier!

    static let general = Logger(subsystem: subsystem, category: "general")

    static let map = Logger(subsystem: subsystem, category: "map")
}
