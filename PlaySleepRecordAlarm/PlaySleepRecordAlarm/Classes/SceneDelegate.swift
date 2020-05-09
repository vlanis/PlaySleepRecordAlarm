//
//  SceneDelegate.swift
//  PlaySleepRecordAlarm
//
//  Created by Vlad Zhaglevskiy on 06.05.2020.
//  Copyright © 2020 None. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    // MARK:- Properties

    var window: UIWindow?
    let applicationNavigator: ApplicationNavigator = ApplicationNavigatorImp()
    
    // MARK:- Properties

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil else {
            return
        }
        
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }
        
        window = UIWindow(frame: windowScene.screen.bounds)
        
        applicationNavigator.setupNavigationStack(window: window!)
        applicationNavigator.presentSleepAlarmScreen()
        
        window?.makeKeyAndVisible()
        window?.windowScene = windowScene
    }
}

