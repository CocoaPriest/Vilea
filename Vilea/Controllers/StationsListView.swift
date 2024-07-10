//
//  StationsListView.swift
//  Vilea
//
//  Created by Konstantin Gonikman on 10.07.24.
//

import SwiftUI
import CoreLocation

struct StationsListView: View {
    @ObservedObject var viewModel: StationsViewModel

    var body: some View {
        List {
            ForEach(viewModel.stations.sorted(by: {
                if $0.maxPower != $1.maxPower {
                    return $0.maxPower > $1.maxPower
                } else {
                    // Also sort by id, otherwise it's an unstable sort
                    return $0.stationId < $1.stationId
                }
            }),
                    id: \.self) { station in
                VStack(alignment: .leading) {
                    Text(station.stationId)
                        .font(.body)
                        .fontWeight(.bold)

                    HStack {
                        Image(systemName: "ev.charger")
                            .foregroundColor(Color(station.availability.tintColor))

                        Text("\(station.maxPower)kW")
                            .font(.body)
                    }

                    if let lastUpdate = station.lastUpdate {
                        Text("Last Update: \(dateFormatter.string(from: lastUpdate))")
                            .font(.footnote)
                    }
                }
            }
        }
        .listStyle(.inset)
    }

    private var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }
}

#Preview {
    let stat1 = UniqueStation(stationId: "1",
                             maxPower: 22,
                             coordinate: CLLocationCoordinate2D(latitude: 22, longitude: 9),
                             lastUpdate: Date(),
                              availability: .available)

    let stat2 = UniqueStation(stationId: "2",
                              maxPower: 11,
                              coordinate: CLLocationCoordinate2D(latitude: 12, longitude: 9),
                              lastUpdate: Date(),
                              availability: .occupied)

    let stat3 = UniqueStation(stationId: "3",
                              maxPower: 22,
                              coordinate: CLLocationCoordinate2D(latitude: 22, longitude: 9),
                              lastUpdate: Date(),
                              availability: .outOfService)

    let stat4 = UniqueStation(stationId: "4",
                              maxPower: 11,
                              coordinate: CLLocationCoordinate2D(latitude: 12, longitude: 9),
                              lastUpdate: Date(),
                              availability: .unknown)

    let stationsViewModel = StationsViewModel()
    stationsViewModel.stations = [stat1, stat2, stat3, stat4]
    return StationsListView(viewModel: stationsViewModel)
}
