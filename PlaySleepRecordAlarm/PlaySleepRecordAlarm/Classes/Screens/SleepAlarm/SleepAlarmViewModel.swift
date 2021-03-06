//
//  SleepAlarmViewModel.swift
//  PlaySleepRecordAlarm
//
//  Created by Vlad Zhaglevskiy on 07.05.2020.
//  Copyright © 2020 None. All rights reserved.
//

import Foundation
import AVFoundation

protocol SleepAlarmViewModel {
    var rows: [RowDescription] {get}
    
    var isRunnning: Bool {get}
    
    func shouldReloadSleepAlarmView(_ handler: (() -> Void)?)
    func shouldReloadPlaybackView(_ handler: (() -> Void)?)
    
    func shouldReloadStateView(_ handler: ((_ state: StateView) -> Void)?)
    
    func play()
    func pause()
    
    func requestPermissions()
}

protocol SleepAlarmPresenter {
    func presentSleepTimerOptionsScreen(_ options: [SleepTimer], completion: @escaping (_ sleepTimer: SleepTimer?) -> Void)
    func presentTimePicker(time: Date?, completion: @escaping (_ time: Date?) -> Void)
    func presentAlarmAlert(message: String?, completion: (() -> Void)?)
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

enum StateView {
    case idle
    case fallingAsleep
    case sleeping
    case alarm
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
        willSet {
            willChangeState()
        }
        
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
    
    private var shouldReloadSleepAlarmViewHandler: (() -> Void)?
    private var shouldReloadPlaybackViewHandler: (() -> Void)?
    private var shouldReloadStateViewHandler: ((_ state: StateView) -> Void)?
    
    private let audioPlayerController: AudioPlayerControllable
    private let audioRecorderController: AudioRecorderControllable
    private let localNotificationController: LocalNotificationControllable
    private let alarmAudioPlayerController: AudioPlayerControllable
    private let presenter: SleepAlarmPresenter
    
    private var sleepSoundStopTimer: Timer?
    private var alarmStateTriggerTimer: Timer?
    
    private var allPermissionsGranted: Bool = false
    
    private var audioSessionInterruptionNotificationObserver: NSObjectProtocol?
    private var shouldTryToResumeOnAudioSessionInterruptionEnded: Bool = false
    
    // MARK:- Initalization
    
    init(audioPlayerController: AudioPlayerControllable, alarmAudioPlayerController: AudioPlayerControllable, audioRecorderController: AudioRecorderControllable, localNotificationController: LocalNotificationControllable, presenter: SleepAlarmPresenter) {
        
        self.audioPlayerController = audioPlayerController
        self.audioRecorderController = audioRecorderController
        self.localNotificationController = localNotificationController
        self.alarmAudioPlayerController = alarmAudioPlayerController
        self.presenter = presenter
        
        state = State.idle
        didChangeState()
        
        self.localNotificationController.didReceiveNotificationAction() { [weak self] _ in
            self?.didReceiveAlarmNotification()
        }
        
        subscribeForAudioSessionInterruptionNotification()
    }
    
    // MARK:- Memory management
    
    deinit {
        unsubscribeFromAudioSessionInterruptionNotification()
    }
    
    // MARK:- Rows
    
    private func reloadRows() {
        let sleepTimerRow = Row<BasicTableViewCell>(configure: { [unowned self] cell, _ in
            cell.textLabel?.text = NSLocalizedString("Sleep Timer", comment: "Sleep Timer")
            cell.detailTextLabel?.text = String(describing: self.sleepTimer.description)
            
            // TODO: change font color based while interactions are disabled
            cell.isUserInteractionEnabled = (self.state == .idle) ? true : false
        }, selection: { [unowned self] _ in
            self.presentSleepTimerOptions()
        }, isEnabled: true)
        
        let alarmRow = Row<BasicTableViewCell>(configure: { [unowned self] cell, _ in
            cell.textLabel?.text = NSLocalizedString("Alarm", comment: "Alarm")
            cell.detailTextLabel?.text = self.alarmTime.shortTimeString
            
            // TODO: change font color while interactions are disabled for better UX
            cell.isUserInteractionEnabled = (self.state == .idle) ? true : false
        }, selection: { [unowned self] _ in
            self.presentAlarmTimePicker()
        }, isEnabled: true)
        
        rows = [sleepTimerRow, alarmRow]
    }
    
    func reloadSleepAlarmView() {
        reloadRows()
        shouldReloadSleepAlarmViewHandler?()
    }
    
    // MARK:- Callbacks
    
    func shouldReloadSleepAlarmView(_ handler: (() -> Void)?) {
        shouldReloadSleepAlarmViewHandler = handler
    }
    
    func shouldReloadPlaybackView(_ handler: (() -> Void)?) {
        shouldReloadPlaybackViewHandler = handler
    }
    
    func shouldReloadStateView(_ handler: ((_ state: StateView) -> Void)?) {
        shouldReloadStateViewHandler = handler
    }
    
    // MARK:- Events
    
    private func didChangeSleepAlarmRelatedData() {
        reloadSleepAlarmView()
    }
    
    private func willChangeState() {
        clearCurrentState()
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
        self.allPermissionsGranted = true
        
        audioRecorderController.requestPermission { [unowned self] allowed in
            self.allPermissionsGranted = self.allPermissionsGranted && allowed
        }
        
        localNotificationController.requestPermission { [unowned self] allowed in
            self.allPermissionsGranted = self.allPermissionsGranted && allowed
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
    
    private func clearCurrentState() {
        switch state {
        case .idle:
            break
            
        case .playing:
            stopSleepSound()
            invalidateSleepSoundStopTimer()
            
        case .recording:
            stopRecording()
            
        case .alarm:
            stopAlarmSound()
            invalidateAlarmStateTriggerTimer()
        }
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
            
        case .alarm:
            isRunnning = true
            presentAlarmView()
            invalidateAlarmStateTriggerTimer()
            playAlarmSound()
        }
        
        updateStateView()
    }
    
    private func resumeCurrentState() {
        switch state {
        case .idle:
            break
            
        case .playing:
            playSleepSound()
            
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
            pauseSleepSound()
            
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
            scheduleAlarmLocalNotification()
            scheduleAlarmStateTriggerTimer()
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
    
    // MARK:- Playing sleep sounds
    
    private func playSleepSound() {
        guard state == .playing && audioPlayerController.isPlaying == false else {
            return
        }
        
        audioPlayerController.play()
        scheduleSleepSoundStopTimer()
    }
    
    private func pauseSleepSound() {
        guard state == .playing && audioPlayerController.isPlaying else {
            return
        }
        
        audioPlayerController.pause()
        invalidateSleepSoundStopTimer()
    }
    
    private func stopSleepSound() {
        guard state == .playing else {
            return
        }
        
        audioPlayerController.stop()
        invalidateSleepSoundStopTimer()
    }
    
    private func finishSleepSoundPlayback() {
        invalidateSleepSoundStopTimer()
        stopSleepSound()
        advanceState()
    }
    
    private func scheduleSleepSoundStopTimer() {
        sleepSoundStopTimer = Timer.scheduledTimer(withTimeInterval: sleepTimer.seconds, repeats: false, block: { [weak self] _ in
            self?.finishSleepSoundPlayback()
        })
    }
    
    private func invalidateSleepSoundStopTimer() {
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
    
    private func scheduleAlarmLocalNotification() {
        localNotificationController.scheduleNotification(title: NSLocalizedString("Alarm went off", comment: "Alarm went off"), message: nil, time: alarmTime, completion: nil)
    }
    
    private func scheduleAlarmStateTriggerTimer() {
        let now = Date()
        let nowComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        
        let alarmTimeComponents = Calendar.current.dateComponents([.hour, .minute], from: alarmTime)
        
        var alarmDateComponents = nowComponents
        alarmDateComponents.hour = alarmTimeComponents.hour
        alarmDateComponents.minute = alarmTimeComponents.minute
        
        if alarmTimeComponents.hour! < nowComponents.hour! {
            alarmDateComponents.day! += 1
        }
        
        if let alarmDate = Calendar.current.date(from: alarmDateComponents) {
            let timerTimeInterval = abs(now.timeIntervalSince1970 - alarmDate.timeIntervalSince1970)
            alarmStateTriggerTimer = Timer.scheduledTimer(withTimeInterval: timerTimeInterval, repeats: false, block: { [unowned self] _ in
                self.proceedToAlarmState()
            })
        }
    }
    
    private func invalidateAlarmStateTriggerTimer() {
        alarmStateTriggerTimer?.invalidate()
        alarmStateTriggerTimer = nil
    }
    
    private func playAlarmSound() {
        guard state == .alarm && alarmAudioPlayerController.isPlaying == false else {
            return
        }
        
        alarmAudioPlayerController.play()
    }
    
    private func stopAlarmSound() {
        guard state == .alarm else {
            return
        }
        
        alarmAudioPlayerController.stop()
    }
    
    // MARK:- Audio Session Interruption
    
    private func subscribeForAudioSessionInterruptionNotification() {
        unsubscribeFromAudioSessionInterruptionNotification()
        audioSessionInterruptionNotificationObserver = NotificationCenter.default.addObserver(forName: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance(), queue: .main) { [unowned self] notification in
            
            guard let userInfo = notification.userInfo,
                let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                    return
            }
            
            switch type {
            case .began:
                if self.isRunnning {
                    self.suspendCurrentState()
                    self.shouldTryToResumeOnAudioSessionInterruptionEnded = true
                }
                
            case .ended:
                guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else {
                    return
                }
                
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                let shouldResume = options.contains(.shouldResume) ? true : false
                if shouldResume && self.shouldTryToResumeOnAudioSessionInterruptionEnded {
                    self.resumeCurrentState()
                }
                
            @unknown default:
                break
            }
        }
    }
    
    private func unsubscribeFromAudioSessionInterruptionNotification() {
        guard audioSessionInterruptionNotificationObserver != nil else {
            return
        }
        
        NotificationCenter.default.removeObserver(audioSessionInterruptionNotificationObserver!)
        audioSessionInterruptionNotificationObserver = nil
    }
    
    // MARK:- State View
    
    private func updateStateView() {
        var stateView: StateView
        switch state {
        case .idle:
            stateView = .idle
        case .playing:
            stateView = .fallingAsleep
        case .recording:
            stateView = .sleeping
        case .alarm:
            stateView = .alarm
        }
        
        shouldReloadStateViewHandler?(stateView)
    }
    
    // MARK:- Presentation
    
    private func presentSleepTimerOptions() {
        presenter.presentSleepTimerOptionsScreen(sleepTimerOptions) { [weak self] sleepTimer in
            guard sleepTimer != nil else {
                return
            }
            
            self?.didSelectSleepTimerOption(sleepTimer!)
        }
    }
    
    private func presentAlarmTimePicker() {
        presenter.presentTimePicker(time: alarmTime) { [weak self] time in
            guard time != nil else {
                return
            }
            
            self?.didSelectAlarmTime(time!)
        }
    }
    
    private func presentAlarmView() {
        presenter.presentAlarmAlert(message: NSLocalizedString("Alarm went off", comment: "Alarm went off")) { [weak self] in
            self?.resetState()
        }
    }
}
