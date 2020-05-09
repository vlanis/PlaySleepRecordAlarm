//
//  AudioRecorderControllerMock.swift
//  PlaySleepRecordAlarmTests
//
//  Created by Vlad Zhaglevskiy on 09.05.2020.
//  Copyright © 2020 None. All rights reserved.
//

import Foundation
@testable import PlaySleepRecordAlarm

final class AudioRecorderControllerMock: AudioRecorderControllable {
    
    var isRecording: Bool = false
    
    func prepare(_ completion: ((Error?) -> Void)?) {
        completion?(nil)
    }
    
    func record(_ completion: ((Error?) -> Void)?) {
        isRecording = true
        completion?(nil)
    }
    
    func pause() {
        isRecording = false
    }
    
    func stop() {
        isRecording = true
    }
    
    var permissionWasGranted: Bool = true
    func requestPermission(_ completion: @escaping (Bool) -> Void) {
        completion(permissionWasGranted)
    }
}
