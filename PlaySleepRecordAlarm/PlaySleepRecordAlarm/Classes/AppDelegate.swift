//
//  AppDelegate.swift
//  PlaySleepRecordAlarm
//
//  Created by Vlad Zhaglevskiy on 06.05.2020.
//  Copyright © 2020 None. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK:- Services
    
    private func configureServices() {
        try? AVAudioSession.sharedInstance().setCategory(.playAndRecord)
    }
    
    // MARK:- Application lifecycle

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureServices()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
