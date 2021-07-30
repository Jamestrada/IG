//
//  TabBarViewController.swift
//  IG
//
//  Created by James Estrada on 5/9/21.
//

import UIKit

final class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpControllers()
    }
    
    private func setUpControllers() {
        guard let username = UserDefaults.standard.string(forKey: "username"),
              let email = UserDefaults.standard.string(forKey: "email") else {
            return
        }
        let currentUser = User(username: username, email: email)
        
        // Define VCs
        let home = HomeViewController()
        let explore = ExploreViewController()
        let camera = CameraViewController()
        let activity = NotificationsViewController()
        let profile = ProfileViewController(user: currentUser)
        
        let nav1 = UINavigationController(rootViewController: home)
        let nav2 = UINavigationController(rootViewController: explore)
        let nav3 = UINavigationController(rootViewController: camera)
        let nav4 = UINavigationController(rootViewController: activity)
        let nav5 = UINavigationController(rootViewController: profile)
        
        nav1.navigationBar.tintColor = .label
        nav5.navigationBar.tintColor = .label
        
        if #available(iOS 14.0, *) {
            home.navigationItem.backButtonDisplayMode = .minimal
            explore.navigationItem.backButtonDisplayMode = .minimal
            camera.navigationItem.backButtonDisplayMode = .minimal
            activity.navigationItem.backButtonDisplayMode = .minimal
            profile.navigationItem.backButtonDisplayMode = .minimal
        } else {
            home.navigationItem.backButtonTitle = ""
            explore.navigationItem.backButtonTitle = ""
            camera.navigationItem.backButtonTitle = ""
            activity.navigationItem.backButtonTitle = ""
            profile.navigationItem.backButtonTitle = ""
        }
        
        // Define tab items
        nav1.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 1)
        nav2.tabBarItem = UITabBarItem(title: "Explore", image: UIImage(systemName: "magnifyingglass"), tag: 2)
        nav3.tabBarItem = UITabBarItem(title: "Camera", image: UIImage(systemName: "camera"), tag: 3)
        nav4.tabBarItem = UITabBarItem(title: "Notifications", image: UIImage(systemName: "bell"), tag: 4)
        nav5.tabBarItem = UITabBarItem(title: UserDefaults.standard.string(forKey: "username")?.uppercased(), image: UIImage(systemName: "person.circle"), tag: 5)
        
        UITabBar.appearance().tintColor = .label // change the color of the selected tab bar item
        
        // Set controllers
        self.setViewControllers([nav1, nav2, nav3, nav4, nav5], animated: false)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        self.navigationController?.setNavigationBarHidden(false, animated: animated)
//    }
}
