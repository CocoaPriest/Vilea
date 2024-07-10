//
//  MapViewController.swift
//  Vilea
//
//  Created by Konstantin Gonikman on 08.07.24.
//

import UIKit
import MapKit
import OSLog
import Combine

class MapViewController: UIViewController {

    private let stationRepository: StationRepository
    private let locationPublisher: Published<CLLocation?>.Publisher
    private var cancellables = Set<AnyCancellable>()

    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        return mapView
    }()

    // MARK: - Initialization

    public init(stationRepository: StationRepository, locationPublisher: Published<CLLocation?>.Publisher) {
        self.stationRepository = stationRepository
        self.locationPublisher = locationPublisher
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        setupMapView()
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

    private func setupBindings() {
        stationRepository.$loadState
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: self.handleLoadState)
            .store(in: &cancellables)

        locationPublisher
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] userLocation in
                self?.updateOwnLocation(userLocation)
            })
            .store(in: &cancellables)
    }

    private func handleLoadState(state: StationRepository.LoadState) {
        switch state {
        case .loaded(let stations):
            OSLog.map.log("number of stations: \(stations.count)")
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotations(stations)
        case .failed:
            OSLog.map.error("failed to load static data")
        default: break
        }
    }

    private func updateOwnLocation(_ location: CLLocation) {
        // Center map on user's location (1km radius)
        let region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 2000,
            longitudinalMeters: 2000
        )

        mapView.setRegion(region, animated: true)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let station = annotation as? UniqueStation else { return nil }

        let identifier = "StationAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: station, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true

            let infoButton = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = infoButton
        } else {
            annotationView?.annotation = station
        }

        annotationView?.glyphImage = UIImage(systemName: "ev.charger")
        annotationView?.markerTintColor = station.availability.tintColor

        return annotationView
    }
}
