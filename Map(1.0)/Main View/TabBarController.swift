//
//  MainTabBarController.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 09/11/2024.
//


import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Create view controllers
        let firstViewController = HomeViewController()
        firstViewController.tabBarItem.image = UIImage(systemName: "house")
        firstViewController.tabBarItem.title = "Home"

        let secondViewController = MapViewController()
        secondViewController.tabBarItem.image = UIImage(systemName: "map")
        secondViewController.tabBarItem.title = "Map"
        
        let thridViewController = ProfileManagementViewController()
        thridViewController.tabBarItem.image = UIImage(systemName: "person")
        thridViewController.tabBarItem.title = "Profile"
        
        let forthViewController = PaymentViewController()
        forthViewController.tabBarItem.image = UIImage(systemName: "wallet.bifold")
        forthViewController.tabBarItem.title = "Wallet"

        // Add view controllers to the Tab Bar Controller
        viewControllers = [ firstViewController, secondViewController, thridViewController, forthViewController]
        
        tabBar.tintColor = .systemBlue  // Selected icon color
        tabBar.backgroundColor = .white
    }
}
