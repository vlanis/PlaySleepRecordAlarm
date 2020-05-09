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

final class ApplicationNavigatorImp: NSObject, ApplicationNavigator, SleepAlarmPresenter, UIViewControllerTransitioningDelegate {
    
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
            localNotificationController: LocalNotificationController(),
            presenter: self
        )
        
        rootNavigationController.viewControllers = [sleepAlarmViewController]
    }
    
    // MARK:- SleepAlarmPresenter
    
    func presentSleepTimerOptionsScreen(_ options: [SleepTimer], completion: @escaping (_ sleepTimer: SleepTimer?) -> Void) {
        let actionSheet = UIAlertController(title: NSLocalizedString("Sleep Timer", comment: "Sleep Timer"), message: nil, preferredStyle: .actionSheet)
        
        options.forEach { sleepTimer in
            let action = UIAlertAction(title: String(describing: sleepTimer), style: .default, handler: { _ in
                completion(sleepTimer)
            })
            actionSheet.addAction(action)
        }
        
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: { _ in
            completion(nil)
        }))
        
        rootNavigationController.present(actionSheet, animated: true)
    }
    
    func presentTimePicker(time: Date?, completion: @escaping (_ time: Date?) -> Void) {
        let timePickerViewController = UIStoryboard.main.instantiateViewController(withIdentifier: TimePickerViewController.storyboardIdentifier) as! TimePickerViewController
        
        timePickerViewController.modalPresentationStyle = .custom
        timePickerViewController.transitioningDelegate = self
        
        timePickerViewController.didFinish { [unowned timePickerViewController] time in
            completion(time)
            timePickerViewController.dismiss(animated: true)
        }
        
        timePickerViewController.didCancel { [unowned timePickerViewController] in
            completion(nil)
            timePickerViewController.dismiss(animated: true)
        }
        
        timePickerViewController.initialDate = time
        
        rootNavigationController.present(timePickerViewController, animated: true)
    }
    
    func presentAlarmAlert(message: String?, completion: (() -> Void)?) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Stop", comment: "Stop"), style: .default, handler: {_ in completion?()}))
        
        rootNavigationController.present(alert, animated: true)
    }
    
    // MARK:- UIViewControllerTransitioningDelegate
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return ContentSizeModalPresentationController(presentedViewController: presented, presenting: source)
    }
}
