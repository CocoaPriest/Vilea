//
//  MainTabBarController.swift
//  Vilea
//
//  Created by Konstantin Gonikman on 08.07.24.
//

import UIKit
import Combine
import OSLog
import Network
import CoreLocation

class MainTabBarController: UITabBarController {

    // TODO: in scenedelegate / viewModel?
    private var timer: Timer?
    private let stationRepository = StationRepository()
    private let locationManager = CLLocationManager()
    private var mapViewController: MapViewController!
    private var listViewController: ListViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        mapViewController = MapViewController(stationRepository: stationRepository)
        mapViewController.tabBarItem.title = "Map"
        mapViewController.tabBarItem.image = UIImage(systemName: "map")
        mapViewController.tabBarItem.selectedImage = UIImage(systemName: "map.fill")

        listViewController = ListViewController(stationRepository: stationRepository)
        listViewController.tabBarItem.title = "List"
        listViewController.tabBarItem.image = UIImage(systemName: "list.bullet.rectangle.portrait")
        listViewController.tabBarItem.selectedImage = UIImage(systemName: "list.bullet.rectangle.portrait.fill")

        viewControllers = [mapViewController, listViewController]

        setupLocationManager()
        
        checkConnectivity { [weak self] isConnected in
            OSLog.general.log("Connectivity status: \(isConnected)")

            if isConnected {
                self?.stationRepository.fetchStations()

                Task { @MainActor in
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

    // MARK: - auto-reload -

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 20.0, repeats: true) { [weak self] _ in
            self?.stationRepository.fetchStations()
        }

        RunLoop.current.add(timer!, forMode: .common)
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
}

extension MainTabBarController: CLLocationManagerDelegate {
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

        mapViewController.updateOwnLocation(location)
        listViewController.userLocation.send(location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        OSLog.map.error("Error: \(error.localizedDescription)")
    }
}
