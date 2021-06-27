//
//  AppDelegate.swift
//  IG
//
//  Created by James Estrada on 5/7/21.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        // mock notification for current user
        let id = NotificationsManager.newIdentifier()
        let model = IGNotification(identifier: id, notificationType: 1, profilePictureUrl: "https://cdn3.iconfinder.com/data/icons/capsocial-round/500/facebook-512.png", username: "markzuckerberg", isFollowing: nil, postId: "123", postUrl: "https://yourwikis.com/wp-content/uploads/2020/01/mark-zuck-img.jpg")
        NotificationsManager.shared.create(notification: model, for: "james")
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

