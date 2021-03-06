//
//  LocalNotificationController.swift
//  PlaySleepRecordAlarm
//
//  Created by Vlad Zhaglevskiy on 08.05.2020.
//  Copyright © 2020 None. All rights reserved.
//

import Foundation
import UserNotifications

protocol LocalNotificationControllable {
    func requestPermission(_ completion: @escaping (_ allowed: Bool) -> Void)
    func scheduleNotification(title: String?, message: String?, time: Date, completion: ((_ identifier: String?, _ error: Error?) -> Void)?)
    func cancelNotification(identifier: String)
    func didReceiveNotificationAction(_ handler: ((_ notification: UNNotification) -> Void)?)
}

final class LocalNotificationController: NSObject, LocalNotificationControllable, UNUserNotificationCenterDelegate {
    
    // MARK:- Properties
    
    private var didReceiveNotificationActionHandler: ((_ notification: UNNotification) -> Void)?
    
    // MARK:- Initialization
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    // MARK:- Permission
    
    func requestPermission(_ completion: @escaping (_ allowed: Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { granted, error in
            completion(granted)
        }
    }
    
    // MARK:- Notifications management
    
    func scheduleNotification(title: String?, message: String? = nil, time: Date, completion: ((_ identifier: String?, _ error: Error?) -> Void)? = nil) {
        let notification = UNMutableNotificationContent()
        notification.title = title ?? ""
        
        var dateComponents = DateComponents()
        dateComponents.calendar = .current
        dateComponents.hour = time.hour
        dateComponents.minute = time.minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let identifier = UUID().uuidString
        let request = UNNotificationRequest(identifier: identifier, content: notification, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if error == nil {
                    completion?(identifier, nil)
                } else {
                    completion?(nil, error)
                }
            }
        }
    }
    
    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func didReceiveNotificationAction(_ handler: ((_ notification: UNNotification) -> Void)?) {
        didReceiveNotificationActionHandler = handler
    }
    
    // MARK:- UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier, UNNotificationDismissActionIdentifier:
                didReceiveNotificationActionHandler?(response.notification)
                break
            
            default:
                break
        }
        
        completionHandler()
    }
}
