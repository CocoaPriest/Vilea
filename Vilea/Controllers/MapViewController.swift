//
//  MapViewController.swift
//  Vilea
//
//  Created by Konstantin Gonikman on 08.07.24.
//

import UIKit
import MapKit
import CoreLocation
import OSLog
import Combine

class MapViewController: UIViewController {

    private let stationRepository: StationRepository
    private let locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()

    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        return mapView
    }()

    // MARK: - Initialization

    public init(stationRepository: StationRepository) {
        self.stationRepository = stationRepository
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        setupMapView()
        setupLocationManager()
        setupBindings()
    }

    private func setupMapView() {
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)

        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: self.view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    private func setupBindings() {
        stationRepository.$loadState
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: self.handleLoadState)
            .store(in: &cancellables)
    }

    private func handleLoadState(state: StationRepository.LoadState) {
        switch state {
        case .loaded(let stations):
            OSLog.general.log("number of stations: \(stations.count)")
            let annotations = stations.map { StationAnnotation(uniqueStation: $0) }
            mapView.addAnnotations(annotations)
        case .failed:
            OSLog.general.error("failed to load static data")
        default: break
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
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

        // Center map on user's location (1km radius)
        let region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 2000,
            longitudinalMeters: 2000
        )

        mapView.setRegion(region, animated: true)
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        OSLog.map.error("Error: \(error.localizedDescription)")
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let stationAnnotation = annotation as? StationAnnotation else { return nil }

        let identifier = "StationAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: stationAnnotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true

            let infoButton = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = infoButton
        } else {
            annotationView?.annotation = stationAnnotation
        }

        annotationView?.glyphImage = UIImage(systemName: "ev.charger")
        annotationView?.markerTintColor = stationAnnotation.isAvailabile ? .systemGreen : .systemBrown

        return annotationView
    }
}
