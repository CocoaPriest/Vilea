//
//  StationsViewModel.swift
//  Vilea
//
//  Created by Konstantin Gonikman on 10.07.24.
//

import Foundation

class StationsViewModel: ObservableObject {
    @Published var stations: [UniqueStation] = []
}
