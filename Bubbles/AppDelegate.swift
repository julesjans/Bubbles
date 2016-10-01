//
//  AppDelegate.swift
//  bubbles
//
//  Created by Julian Jans on 08/09/2015.
//  Copyright (c) 2015 Julian Jans. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        BubbleSettings.setStandardSettings()
        return true
    }
}
