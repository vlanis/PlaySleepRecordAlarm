//
//  SleepAlarmViewModelTests.swift
//  PlaySleepRecordAlarmTests
//
//  Created by Vlad Zhaglevskiy on 09.05.2020.
//  Copyright © 2020 None. All rights reserved.
//

import XCTest
@testable import PlaySleepRecordAlarm

class SleepAlarmViewModelTests: XCTestCase {
    
    // MARK:- Properties
    
    var sleepAlarmViewModel: SleepAlarmViewModelImp!
    
    var audioPlayerController: AudioPlayerControllerMock!
    var alarmAudioPlayerController: AudioPlayerControllerMock!
    var audioRecorderController: AudioRecorderControllerMock!
    var localNotificationController: LocalNotificationControllerMock!
    var presenter: SleepAlarmPresenterMock!
    
    // MARK:- Tests lifecycle

    override func setUp() {
        audioPlayerController = AudioPlayerControllerMock()
        alarmAudioPlayerController = AudioPlayerControllerMock()
        audioRecorderController = AudioRecorderControllerMock()
        localNotificationController = LocalNotificationControllerMock()
        presenter = SleepAlarmPresenterMock()
        
        sleepAlarmViewModel = SleepAlarmViewModelImp(
            audioPlayerController: audioPlayerController,
            alarmAudioPlayerController: alarmAudioPlayerController,
            audioRecorderController: audioRecorderController,
            localNotificationController: localNotificationController,
            presenter: presenter
        )
    }

    override func tearDown() {
    }
    
    // MARK:- Tests
    
    func testNoPermissions() {
        audioRecorderController.permissionWasGranted = false
        localNotificationController.permissionWasGranted = false
        
        sleepAlarmViewModel.requestPermissions()
        sleepAlarmViewModel.play()
        
        XCTAssertFalse(sleepAlarmViewModel.isRunnning)
    }
}
