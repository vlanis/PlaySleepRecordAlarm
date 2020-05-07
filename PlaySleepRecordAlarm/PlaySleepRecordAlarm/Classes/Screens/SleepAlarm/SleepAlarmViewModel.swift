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
    
    func shouldPresentSleepTimerOptions(_ handler: ((_ options: [SleepTimer]) -> Void)?)
    func didSelectSleepTimerOption(_ sleepTimer: SleepTimer)
    
    func shouldReloadSleepAlarmView(_ handler: (() -> Void)?)
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
    
    private var state = State.idle
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
    
    // MARK:- Initalization
    
    init() {
        reloadRows()
    }
    
    // MARK:- Rows
    
    private func reloadRows() {
        let sleepTimerRow = Row<BasicTableViewCell>(configure: { [unowned self] cell, _ in
            cell.textLabel?.text = NSLocalizedString("Sleep Timer", comment: "Sleep Timer")
            cell.detailTextLabel?.text = String(describing: self.sleepTimer.description)
        }, selection: { [unowned self] _ in
            self.shouldPresentSleepTimerOptionsHandler?(self.sleepTimerOptions)
        }, isEnabled: true)
        
        let alarmRow = Row<BasicTableViewCell>(configure: { [unowned self] cell, _ in
            cell.textLabel?.text = NSLocalizedString("Alarm", comment: "Alarm")
            cell.detailTextLabel?.text = self.alarmTime.shortTimeString
        }, selection: { _ in
            
        }, isEnabled: true)
        
        rows = [sleepTimerRow, alarmRow]
    }
    
    // MARK:- Callbacks
    
    func shouldPresentSleepTimerOptions(_ handler: ((_ options: [SleepTimer]) -> Void)?) {
        shouldPresentSleepTimerOptionsHandler = handler
    }
    
    func shouldReloadSleepAlarmView(_ handler: (() -> Void)?) {
        shouldReloadSleepAlarmViewHandler = handler
    }
    
    // MARK:- Events
    
    private func didChangeSleepAlarmRelatedData() {
        reloadRows()
        shouldReloadSleepAlarmViewHandler?()
    }
    
    // MARK:- Sleep Timer
    
    func didSelectSleepTimerOption(_ sleepTimer: SleepTimer) {
        self.sleepTimer = sleepTimer
        didChangeSleepAlarmRelatedData()
    }
}
