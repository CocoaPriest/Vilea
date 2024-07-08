//
//  MainTabBarController.swift
//  Vilea
//
//  Created by Konstantin Gonikman on 08.07.24.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let mapViewController = MapViewController()
        mapViewController.tabBarItem.title = "Map"
        mapViewController.tabBarItem.image = UIImage(systemName: "map")
        mapViewController.tabBarItem.selectedImage = UIImage(systemName: "map.fill")

        let listViewController = ListViewController()
        listViewController.tabBarItem.title = "List"
        listViewController.tabBarItem.image = UIImage(systemName: "list.bullet.rectangle.portrait")
        listViewController.tabBarItem.selectedImage = UIImage(systemName: "list.bullet.rectangle.portrait.fill")

        viewControllers = [mapViewController, listViewController]
    }
}
