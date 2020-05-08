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
}

final class LocalNotificationController: LocalNotificationControllable {
    
    // MARK:- Persmission
    
    func requestPermission(_ completion: @escaping (_ allowed: Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert]) { granted, error in
            completion(granted)
        }
    }
}
