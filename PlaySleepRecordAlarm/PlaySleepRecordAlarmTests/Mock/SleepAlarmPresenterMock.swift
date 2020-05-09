//
//  SleepAlarmPresenterMock.swift
//  PlaySleepRecordAlarmTests
//
//  Created by Vlad Zhaglevskiy on 09.05.2020.
//  Copyright © 2020 None. All rights reserved.
//

import Foundation
@testable import PlaySleepRecordAlarm

final class SleepAlarmPresenterMock: SleepAlarmPresenter {
    
    var selectedSleepTimer: SleepTimer?
    func presentSleepTimerOptionsScreen(_ options: [SleepTimer], completion: @escaping (SleepTimer?) -> Void) {
        completion(selectedSleepTimer)
    }
    
    var selectedTime: Date?
    func presentTimePicker(time: Date?, completion: @escaping (Date?) -> Void) {
        completion(selectedTime)
    }
    
    func presentAlarmAlert(message: String?, completion: (() -> Void)?) {
        completion?()
    }
}
