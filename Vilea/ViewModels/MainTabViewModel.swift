//
//  MainTabViewModel.swift
//  Vilea
//
//  Created by Konstantin Gonikman on 10.07.24.
//

import Foundation
import Network
import CoreLocation
import OSLog

class MainTabViewModel: NSObject {
    private var timer: Timer?
    private(set) var stationRepository = StationRepository()
    private let locationManager = CLLocationManager()

    @Published var userLocation: CLLocation? = nil

    override init() {
        super.init()

        setupLocationManager()

        checkConnectivity { [weak self] isConnected in
            OSLog.general.log("Connectivity status: \(isConnected)")

            if isConnected {
                self?.stationRepository.fetchStations()

                Task { @MainActor [weak self] in
                    self?.startTimer()
                }
            } else {
                self?.stationRepository.loadCachedData()
            }
        }
    }

    // MARK: - location -
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    // MARK: - connectivity -

    func checkConnectivity(completion: @escaping (Bool) -> Void) {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitor")

        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                completion(true)
            } else {
                completion(false)
            }
            monitor.cancel()
        }

        monitor.start(queue: queue)
    }

    // MARK: - auto-reload -

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 20.0, repeats: true) { [weak self] _ in
            self?.stationRepository.fetchStations()
        }

        RunLoop.current.add(timer!, forMode: .common)
    }
}

extension MainTabViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .denied:
            OSLog.map.error("Error: location Authorization denied.")
        default:
            OSLog.map.warning("-")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        OSLog.map.log("User's location: \(location.coordinate.latitude),\(location.coordinate.longitude)")

        manager.stopUpdatingLocation()

        userLocation = location
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        OSLog.map.error("Error: \(error.localizedDescription)")
    }
}
