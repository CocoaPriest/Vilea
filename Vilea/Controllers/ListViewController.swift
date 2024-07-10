//
//  ListViewController.swift
//  Vilea
//
//  Created by Konstantin Gonikman on 08.07.24.
//

import UIKit
import SwiftUI
import OSLog
import Combine
import CoreLocation

class ListViewController: UIViewController {

    private let stationRepository: StationRepository
    private var stationsViewModel = StationsViewModel()
    private var cancellables = Set<AnyCancellable>()

    private(set) var userLocation: PassthroughSubject<CLLocation, Never> = .init()

    private lazy var stationsListView: UIHostingController<StationsListView> = {
        return UIHostingController(rootView: StationsListView(viewModel: stationsViewModel))
    }()

    // MARK: - Initialization

    public init(stationRepository: StationRepository) {
        self.stationRepository = stationRepository
        super.init(nibName: nil, bundle: nil)

        self.setupBindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground

        stationsListView.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChild(stationsListView)
        self.view.addSubview(stationsListView.view)

        NSLayoutConstraint.activate([
            stationsListView.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            stationsListView.view.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            stationsListView.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            stationsListView.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }

    private func setupBindings() {
        stationRepository.$loadState
            .combineLatest(userLocation)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: self.handleLoadState)
            .store(in: &cancellables)
    }

    private func handleLoadState(state: StationRepository.LoadState, loc: CLLocation) {
        switch state {
        case .loaded(let stations):
            OSLog.general.log("number of stations: \(stations.count); location: \(loc)")

            let filteredStations = stations.filter { station in
                let location = CLLocation(latitude: station.coordinate.latitude,
                                          longitude: station.coordinate.longitude)
                let distance = location.distance(from: loc)
                return distance < 1000
            }
            stationsViewModel.stations = filteredStations
        case .failed:
            OSLog.general.error("failed to load static data")
        default: break
        }
    }
}
