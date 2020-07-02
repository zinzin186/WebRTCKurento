//
//  AppDelegate.swift
//  LiveStreamDemo
//
//  Created by NamViet on 6/23/20.
//  Copyright © 2020 Dinh Le. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        let vc = HomeViewController(nibName: "HomeViewController", bundle: nil)
        let navi = UINavigationController(rootViewController: vc)
        self.window?.rootViewController = navi
        self.window?.makeKeyAndVisible()
        return true
    }

    // MARK: UISceneSession Lifecycle

}

