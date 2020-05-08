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
    
    func play()
    func pause()
}

enum SleepTimer: CustomStringConvertible {
    case off
    case duration(minutes: UInt)
    
    var description: String {
        switch self {
        case .off:
            return NSLocalizedString("off", comment: "off")
        case .duration(let minutes):
            return String(minutes) + " " + "min"
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
    
    private var sleepTimer: SleepTimer = .duration(minutes: 20)
    private var alarmTime = Date.fromComponents(hour: 8, minute: 30)!
    
    private var sleepTimerOptions: [SleepTimer] = [.off,
                                                   .duration(minutes: 1),
                                                   .duration(minutes: 5),
                                                   .duration(minutes: 10),
                                                   .duration(minutes: 15),
                                                   .duration(minutes: 20)]
    
    private var shouldPresentSleepTimerOptionsHandler: ((_ options: [SleepTimer]) -> Void)?
    private var shouldReloadSleepAlarmViewHandler: (() -> Void)?
    private var shouldPresentAlarmTimePickerHandler: ((_ currentAlarmTime: Date) -> Void)?
    private var shouldReloadPlaybackViewHandler: (() -> Void)?
    
    // MARK:- Initalization
    
    init() {
        state = State.idle
        didChangeState()
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
            
            // TODO: change font color based while interactions are disabled
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
    
    // MARK:- States
    
    func play() {
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
    
    private func configureAsPerCurrentState() {
        switch state {
        case .idle:
            isRunnning = false
            reloadSleepAlarmView()
            break
            
        case .playing:
            isRunnning = true
            reloadSleepAlarmView()
            break
            
        case .recording:
            break
            
        case .alarm:
            break
        }
    }
    
    private func resumeCurrentState() {
        isRunnning = true
    }
    
    private func suspendCurrentState() {
        isRunnning = false
    }
    
    private func advanceState() {
        switch state {
        case .idle:
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
}
