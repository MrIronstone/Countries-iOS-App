//
//  MainTabbarViewController.swift
//  Countries
//
//  Created by admin on 30.09.2022.
//

import UIKit

class MainTabbarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        view.tintColor = .label
        
        // this is for stacking the view controllers
        let vc1 = UINavigationController(rootViewController: HomeViewController())
        let vc2 = UINavigationController(rootViewController: SavedViewController())
        
        
        
        vc1.tabBarItem.title = "Home"
        vc1.tabBarItem.image = UIImage(systemName: "house")
        vc1.tabBarItem.selectedImage = UIImage(systemName: "house.fill")
        
        vc2.tabBarItem.title = "Saved"
        vc2.tabBarItem.image = UIImage(systemName: "heart")
        vc2.tabBarItem.selectedImage = UIImage(systemName: "heart.fill")

        
        // this sets the view controllers to the tabbar
        setViewControllers([vc1, vc2], animated: true)
    }
}
