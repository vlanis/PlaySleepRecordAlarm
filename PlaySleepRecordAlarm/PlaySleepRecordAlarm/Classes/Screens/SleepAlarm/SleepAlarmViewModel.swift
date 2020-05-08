//
//  SleepAlarmViewModel.swift
//  PlaySleepRecordAlarm
//
//  Created by Vlad Zhaglevskiy on 07.05.2020.
//  Copyright © 2020 None. All rights reserved.
//

import Foundation

protocol SleepAlarmViewModel {
    var rows: [RowDescription] {get}
    
    var isRunnning: Bool {get}
    
    func shouldPresentSleepTimerOptions(_ handler: ((_ options: [SleepTimer]) -> Void)?)
    func didSelectSleepTimerOption(_ sleepTimer: SleepTimer)
    
    func shouldReloadSleepAlarmView(_ handler: (() -> Void)?)
    func shouldReloadPlaybackView(_ handler: (() -> Void)?)
    
    func shouldPresentAlarmTimePicker(_ handler: ((_ currentAlarmTime: Date) -> Void)?)
    func didSelectAlarmTime(_ alarmTime: Date)
    
    func shouldPresentAlarmView(_ handler: ((_ message: String?, _ completion: @escaping () -> Void) -> Void)?)
    
    func play()
    func pause()
    
    func requestPermissions()
}

enum SleepTimer: CustomStringConvertible {
    case off
    case minutes(_ minutes: UInt)
    case seconds(_ seconds: TimeInterval)
    
    var description: String {
        switch self {
        case .off:
            return NSLocalizedString("off", comment: "off")
        case .minutes(let minutes):
            return String(minutes) + " " + "min"
        case .seconds(let seconds):
            return String(format: "%.0f sec", seconds)
        }
    }
    
    var seconds: TimeInterval {
        switch self {
        case .off:
            return 0
        case .minutes(let minutes):
            return TimeInterval(minutes * 60)
        case .seconds(let seconds):
            return seconds
        }
    }
}

final class SleepAlarmViewModelImp: SleepAlarmViewModel {
    
    // MARK:-
    
    fileprivate enum State {
        case idle
        case playing
        case recording
        case alarm
    }
    
    // MARK:- Properties
    
    private(set) var rows: [RowDescription] = []
    private(set) var isRunnning: Bool = false {
        didSet {
            didChangePlaybackState()
        }
    }
    
    private var state: State {
        didSet {
            didChangeState()
        }
    }
    
    private var sleepTimer: SleepTimer = .minutes(20)
    private var alarmTime = Date.fromComponents(hour: 8, minute: 30)!
    
    private var sleepTimerOptions: [SleepTimer] = [.off,
                                                   .seconds(10),
                                                   .minutes(1),
                                                   .minutes(5),
                                                   .minutes(10),
                                                   .minutes(15),
                                                   .minutes(20)]
    
    private var shouldPresentSleepTimerOptionsHandler: ((_ options: [SleepTimer]) -> Void)?
    private var shouldReloadSleepAlarmViewHandler: (() -> Void)?
    private var shouldPresentAlarmTimePickerHandler: ((_ currentAlarmTime: Date) -> Void)?
    private var shouldReloadPlaybackViewHandler: (() -> Void)?
    private var shouldPresentAlarmViewHandler: ((_ message: String?, _ completion: @escaping () -> Void) -> Void)?
    
    private let audioPlayerController: AudioPlayerControllable
    private let audioRecorderController: AudioRecorderControllable
    private let localNotificationController: LocalNotificationControllable
    
    private var sleepSoundStopTimer: Timer?
    
    private var allPermissionsGranted: Bool = true
    
    // MARK:- Initalization
    
    init(audioPlayerController: AudioPlayerControllable, audioRecorderController: AudioRecorderControllable, localNotificationController: LocalNotificationControllable) {
        self.audioPlayerController = audioPlayerController
        self.audioRecorderController = audioRecorderController
        self.localNotificationController = localNotificationController
        
        state = State.idle
        didChangeState()
        
        self.localNotificationController.didReceiveNotification { [weak self] _ in
            self?.didReceiveAlarmNotification()
        }
        
        self.localNotificationController.didReceiveNotificationAction() { [weak self] _ in
            self?.didReceiveAlarmNotification()
        }
    }
    
    // MARK:- Rows
    
    private func reloadRows() {
        let sleepTimerRow = Row<BasicTableViewCell>(configure: { [unowned self] cell, _ in
            cell.textLabel?.text = NSLocalizedString("Sleep Timer", comment: "Sleep Timer")
            cell.detailTextLabel?.text = String(describing: self.sleepTimer.description)
            
            // TODO: change font color based while interactions are disabled
            cell.isUserInteractionEnabled = (self.state == .idle) ? true : false
        }, selection: { [unowned self] _ in
            self.shouldPresentSleepTimerOptionsHandler?(self.sleepTimerOptions)
        }, isEnabled: true)
        
        let alarmRow = Row<BasicTableViewCell>(configure: { [unowned self] cell, _ in
            cell.textLabel?.text = NSLocalizedString("Alarm", comment: "Alarm")
            cell.detailTextLabel?.text = self.alarmTime.shortTimeString
            
            // TODO: change font color while interactions are disabled for better UX
            cell.isUserInteractionEnabled = (self.state == .idle) ? true : false
        }, selection: { [unowned self] _ in
            self.shouldPresentAlarmTimePickerHandler?(self.alarmTime)
        }, isEnabled: true)
        
        rows = [sleepTimerRow, alarmRow]
    }
    
    func reloadSleepAlarmView() {
        reloadRows()
        shouldReloadSleepAlarmViewHandler?()
    }
    
    // MARK:- Callbacks
    
    func shouldPresentSleepTimerOptions(_ handler: ((_ options: [SleepTimer]) -> Void)?) {
        shouldPresentSleepTimerOptionsHandler = handler
    }
    
    func shouldReloadSleepAlarmView(_ handler: (() -> Void)?) {
        shouldReloadSleepAlarmViewHandler = handler
    }
    
    func shouldPresentAlarmTimePicker(_ handler: ((_ currentAlarmTime: Date) -> Void)?) {
        shouldPresentAlarmTimePickerHandler = handler
    }
    
    func shouldReloadPlaybackView(_ handler: (() -> Void)?) {
        shouldReloadPlaybackViewHandler = handler
    }
    
    func shouldPresentAlarmView(_ handler: ((_ message: String?, _ completion: @escaping () -> Void) -> Void)?) {
        shouldPresentAlarmViewHandler = handler
    }
    
    // MARK:- Events
    
    private func didChangeSleepAlarmRelatedData() {
        reloadSleepAlarmView()
    }
    
    private func didChangeState() {
        configureAsPerCurrentState()
    }
    
    private func didChangePlaybackState() {
        reloadPlaybackView()
    }
    
    private func didReceiveAlarmNotification() {
        proceedToAlarmState()
    }
    
    // MARK:- Sleep Timer
    
    func didSelectSleepTimerOption(_ sleepTimer: SleepTimer) {
        self.sleepTimer = sleepTimer
        didChangeSleepAlarmRelatedData()
    }
    
    // MARK:- Alarm Time
    
    func didSelectAlarmTime(_ alarmTime: Date) {
        self.alarmTime = alarmTime
        didChangeSleepAlarmRelatedData()
    }
    
    // MARK:- Permissions
    
    func requestPermissions() {
        audioRecorderController.requestPermission { [unowned self] allowed in
            self.allPermissionsGranted = self.allPermissionsGranted || allowed
        }
        
        localNotificationController.requestPermission { [unowned self] allowed in
            self.allPermissionsGranted = self.allPermissionsGranted || allowed
        }
    }
    
    // MARK:- States
    
    func play() {
        guard allPermissionsGranted else {
            return
        }
        
        guard isRunnning == false else {
            return
        }
        
        switch state {
        case .idle:
            advanceState()
            
        case .alarm:
            break
            
        default:
            resumeCurrentState()
        }
    }
    
    func pause() {
        guard isRunnning else {
            return
        }
        
        switch state {
        case .idle:
            break
            
        case .alarm:
            break
            
        default:
            suspendCurrentState()
        }
    }
    
    private func resetState() {
        state = .idle
    }
    
    private func proceedToAlarmState() {
        state = .alarm
    }
    
    private func configureAsPerCurrentState() {
        switch state {
        case .idle:
            isRunnning = false
            reloadSleepAlarmView()
            
        case .playing:
            switch sleepTimer {
            case .off:
                advanceState()
            default:
                resumeCurrentState()
                reloadSleepAlarmView()
            }
            
        case .recording:
            prepareRecording()
            resumeCurrentState()
            reloadSleepAlarmView()
            break
            
        case .alarm:
            presentAlarmView()
            break
        }
    }
    
    private func resumeCurrentState() {
        switch state {
        case .idle:
            break
            
        case .playing:
            playSound()
            
        case .recording:
            starRecording()
            
        case .alarm:
            break
        }
        
        isRunnning = true
    }
    
    private func suspendCurrentState() {
        switch state {
        case .idle:
            break
            
        case .playing:
            pauseSound()
            
        case .recording:
            pauseRecording()
            
        case .alarm:
            break
        }
        
        isRunnning = false
    }
    
    private func advanceState() {
        switch state {
        case .idle:
            scheduleAlarmNotification()
            state = .playing
            
        case .playing:
            state = .recording
            
        case .recording:
            state = .alarm
            
        case .alarm:
            break
        }
    }
    
    private func reloadPlaybackView() {
        shouldReloadPlaybackViewHandler?()
    }
    
    // MARK:- Playing sounds
    
    private func playSound() {
        guard state == .playing && audioPlayerController.isPlaying == false else {
            return
        }
        
        audioPlayerController.play()
        scheduleSoundStopTimer()
    }
    
    private func pauseSound() {
        guard state == .playing && audioPlayerController.isPlaying else {
            return
        }
        
        audioPlayerController.pause()
        invalidateSoundStopTimer()
    }
    
    private func stopSound() {
        guard state == .playing else {
            return
        }
        
        audioPlayerController.stop()
        invalidateSoundStopTimer()
    }
    
    private func finishSoundPlayback() {
        invalidateSoundStopTimer()
        stopSound()
        advanceState()
    }
    
    private func scheduleSoundStopTimer() {
        sleepSoundStopTimer = Timer.scheduledTimer(withTimeInterval: sleepTimer.seconds, repeats: false, block: { [weak self] _ in
            self?.finishSoundPlayback()
        })
    }
    
    private func invalidateSoundStopTimer() {
        sleepSoundStopTimer?.invalidate()
        sleepSoundStopTimer = nil
    }
    
    // MARK:- Recording audio
    
    private func prepareRecording() {
        audioRecorderController.prepare(nil)
    }
    
    private func starRecording() {
        audioRecorderController.record(nil)
    }
    
    private func pauseRecording() {
        audioRecorderController.pause()
    }
    
    private func stopRecording() {
        audioRecorderController.stop()
    }
    
    // MARK:- Alarm
    
    private func scheduleAlarmNotification() {
        localNotificationController.scheduleNotification(title: NSLocalizedString("Alarm went off", comment: "Alarm went off"), message: nil, time: alarmTime, completion: nil)
    }
    
    private func presentAlarmView() {
        shouldPresentAlarmViewHandler?(NSLocalizedString("Alarm went off", comment: "Alarm went off"), { [weak self] in
            self?.resetState()
        })
    }
}
