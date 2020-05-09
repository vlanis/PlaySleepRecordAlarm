//
//  LocalNotificationControllerMock.swift
//  PlaySleepRecordAlarmTests
//
//  Created by Vlad Zhaglevskiy on 09.05.2020.
//  Copyright © 2020 None. All rights reserved.
//

import Foundation
import NotificationCenter
@testable import PlaySleepRecordAlarm

final class LocalNotificationControllerMock: LocalNotificationControllable {
    
    private var didReceiveNotificationActionHandler: ((_ notification: UNNotification) -> Void)?
    
    var permissionWasGranted: Bool = true
    func requestPermission(_ completion: @escaping (Bool) -> Void) {
        completion(permissionWasGranted)
    }
    
    func scheduleNotification(title: String?, message: String?, time: Date, completion: ((String?, Error?) -> Void)?) {
        completion?(UUID().uuidString, nil)
    }
    
    func cancelNotification(identifier: String) {
    }
    
    func didReceiveNotificationAction(_ handler: ((UNNotification) -> Void)?) {
        didReceiveNotificationActionHandler = handler
    }
}
