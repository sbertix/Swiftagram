//
//  AppDelegate.swift
//  Followers
//
//  Created by Stefano Bertagno on 10/03/2020.
//  Copyright © 2020 Stefano Bertagno. All rights reserved.
//

import UIKit

import ComposableRequest
import SwiftagramKeychain

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Delete keychain when reinstalling the app.
        if !UserDefaults.standard.bool(forKey: "launched.before") {
            KeychainStorage().removeAll()
            UserDefaults.standard.set(true, forKey: "launched.before")
            UserDefaults.standard.synchronize()
        }
        // Update the `Requester`.
        Requester.default = .init(configuration: .init(sessionConfiguration: .default,
                                                       requestQueue: .main,
                                                       mapQueue: .global(qos: .userInitiated),
                                                       responseQueue: .main,
                                                       waiting: 0.5...1.5))
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called
        // shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}
