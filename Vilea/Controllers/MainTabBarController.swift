//
//  MainTabBarController.swift
//  Vilea
//
//  Created by Konstantin Gonikman on 08.07.24.
//

import UIKit

class MainTabBarController: UITabBarController {
    private let viewModel: MainTabViewModel
    private var mapViewController: MapViewController!
    private var listViewController: ListViewController!

    // MARK: - Initialization

    public init(viewModel: MainTabViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mapViewController = MapViewController(stationRepository: viewModel.stationRepository,
                                              locationPublisher: viewModel.$userLocation)
        mapViewController.tabBarItem.title = "Map"
        mapViewController.tabBarItem.image = UIImage(systemName: "map")
        mapViewController.tabBarItem.selectedImage = UIImage(systemName: "map.fill")

        listViewController = ListViewController(stationRepository: viewModel.stationRepository,
                                                locationPublisher: viewModel.$userLocation)
        listViewController.tabBarItem.title = "List"
        listViewController.tabBarItem.image = UIImage(systemName: "list.bullet.rectangle.portrait")
        listViewController.tabBarItem.selectedImage = UIImage(systemName: "list.bullet.rectangle.portrait.fill")

        viewControllers = [mapViewController, listViewController]
    }
}
