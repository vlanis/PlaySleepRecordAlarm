//
//  ApplicationNavigator.swift
//  PlaySleepRecordAlarm
//
//  Created by Vlad Zhaglevskiy on 09.05.2020.
//  Copyright © 2020 None. All rights reserved.
//

import UIKit

protocol ApplicationNavigator {
    func setupNavigationStack(window: UIWindow)
    func presentSleepAlarmScreen()
}

final class ApplicationNavigatorImp: ApplicationNavigator {
    
    // MARK:- Properties
    
    private var rootNavigationController: UINavigationController!
    
    // MARK:- Navigation
    
    func setupNavigationStack(window: UIWindow) {
        rootNavigationController = UINavigationController()
        window.rootViewController = rootNavigationController
    }
    
    func presentSleepAlarmScreen() {
        let sleepAlarmViewController = UIStoryboard.main.instantiateViewController(identifier: SleepAlarmViewController.storyboardIdentifier) as! SleepAlarmViewController
        
        sleepAlarmViewController.viewModel = SleepAlarmViewModelImp(
            audioPlayerController: AudioPlayerController(audioFileNamed: "nature", fileExtension: "m4a", loop: true)!,
            alarmAudioPlayerController: AudioPlayerController(audioFileNamed: "alarm", fileExtension: "m4a", loop: true)!,
            audioRecorderController: AudioRecorderController(),
            localNotificationController: LocalNotificationController()
        )
        
        rootNavigationController.viewControllers = [sleepAlarmViewController]
    }
}
