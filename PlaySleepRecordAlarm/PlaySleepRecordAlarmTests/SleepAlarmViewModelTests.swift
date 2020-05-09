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
        
        audioRecorderController.permissionWasGranted = true
        localNotificationController.permissionWasGranted = true
        
        sleepAlarmViewModel = SleepAlarmViewModelImp(
            audioPlayerController: audioPlayerController,
            alarmAudioPlayerController: alarmAudioPlayerController,
            audioRecorderController: audioRecorderController,
            localNotificationController: localNotificationController,
            presenter: presenter
        )
    }

    override func tearDown() {
        sleepAlarmViewModel.shouldReloadStateView(nil)
    }
    
    // MARK:- Tests
    
    func testNoPermissions() {
        audioRecorderController.permissionWasGranted = false
        localNotificationController.permissionWasGranted = false
        
        sleepAlarmViewModel.requestPermissions()
        sleepAlarmViewModel.play()
        
        XCTAssertFalse(sleepAlarmViewModel.isRunnning)
    }
    
    func testPermissionsGranted() {
        audioRecorderController.permissionWasGranted = true
        localNotificationController.permissionWasGranted = true
        
        sleepAlarmViewModel.requestPermissions()
        sleepAlarmViewModel.play()
        
        XCTAssertTrue(sleepAlarmViewModel.isRunnning)
    }
    
    func testSleepAudioIsPlaying() {
        sleepAlarmViewModel.requestPermissions()
        
        presenter.selectedSleepTimer = .seconds(10)
        sleepAlarmViewModel.rows[0].handleSelection(at: IndexPath())
        
        sleepAlarmViewModel.play()
        XCTAssertTrue(audioPlayerController.isPlaying)
    }
    
    func testSleepAudioIsPaused() {
        sleepAlarmViewModel.requestPermissions()
        
        presenter.selectedSleepTimer = .seconds(10)
        sleepAlarmViewModel.rows[0].handleSelection(at: IndexPath())
        
        sleepAlarmViewModel.play()
        sleepAlarmViewModel.pause()
        
        XCTAssertFalse(audioPlayerController.isPlaying)
    }
    
    func testFallingAsleepViewState() {
        let fallingAsleepExpectation = expectation(description: "Switch to FallingAsleep state")
        
        sleepAlarmViewModel.requestPermissions()
        
        presenter.selectedSleepTimer = .seconds(10)
        sleepAlarmViewModel.rows[0].handleSelection(at: IndexPath())
        
        sleepAlarmViewModel.shouldReloadStateView { stateView in
            if stateView == .fallingAsleep {
                fallingAsleepExpectation.fulfill()
            } else {
                XCTAssertTrue(false)
            }
        }
        
        sleepAlarmViewModel.play()
        
        wait(for: [fallingAsleepExpectation], timeout: 10)
    }
    
    func testSleepTimerSetToOff_fastSwitchToFallingAsleepViewState() {
        let sleepingExpectation = expectation(description: "Switch to Sleeping state")
        sleepingExpectation.expectedFulfillmentCount = 2
        sleepingExpectation.assertForOverFulfill = true
        
        sleepAlarmViewModel.requestPermissions()
        
        presenter.selectedSleepTimer = .off
        sleepAlarmViewModel.rows[0].handleSelection(at: IndexPath())
        
        sleepAlarmViewModel.shouldReloadStateView { stateView in
            if stateView == .sleeping || stateView == .fallingAsleep {
                sleepingExpectation.fulfill()
            } else {
                XCTAssertTrue(false)
            }
        }
        
        sleepAlarmViewModel.play()
        
        wait(for: [sleepingExpectation], timeout: 3)
    }
    
    func testAudioIsRecording() {
        let isRecordingExpectation = expectation(description: "Recording")
        
        sleepAlarmViewModel.requestPermissions()
        
        presenter.selectedSleepTimer = .seconds(1)
        sleepAlarmViewModel.rows[0].handleSelection(at: IndexPath())
        
        sleepAlarmViewModel.shouldReloadStateView { [unowned self] stateView in
            if stateView == .sleeping && self.audioRecorderController.isRecording {
                isRecordingExpectation.fulfill()
            }
        }
        
        sleepAlarmViewModel.play()
        
        wait(for: [isRecordingExpectation], timeout: 3)
    }
}
