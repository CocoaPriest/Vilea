//
//  MainTabBarController.swift
//  Vilea
//
//  Created by Konstantin Gonikman on 08.07.24.
//

import UIKit
import Combine
import OSLog

class MainTabBarController: UITabBarController {

    // TODO: in scenedelegate / viewModel?
    private var timer: Timer?
    private let stationRepository = StationRepository()

    override func viewDidLoad() {
        super.viewDidLoad()

        let mapViewController = MapViewController(stationRepository: stationRepository)
        mapViewController.tabBarItem.title = "Map"
        mapViewController.tabBarItem.image = UIImage(systemName: "map")
        mapViewController.tabBarItem.selectedImage = UIImage(systemName: "map.fill")

        let listViewController = ListViewController()
        listViewController.tabBarItem.title = "List"
        listViewController.tabBarItem.image = UIImage(systemName: "list.bullet.rectangle.portrait")
        listViewController.tabBarItem.selectedImage = UIImage(systemName: "list.bullet.rectangle.portrait.fill")

        viewControllers = [mapViewController, listViewController]

        stationRepository.fetchStations()
        startTimer()

        // for offline:
//        stationRepository.loadCachedData()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 20.0, repeats: true) { [weak self] _ in
            self?.timerFired()
        }

        RunLoop.current.add(timer!, forMode: .common)
    }

    private func timerFired() {
        stationRepository.fetchStations()
    }
}
