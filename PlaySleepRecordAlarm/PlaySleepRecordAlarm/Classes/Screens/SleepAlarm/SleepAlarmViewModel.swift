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
}

enum SleepTimer: CustomStringConvertible {
    case off
    case duration(minutes: UInt)
    
    var description: String {
        switch self {
        case .off:
            return NSLocalizedString("Off", comment: "Off")
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
    
    // MARK:- Initalization
    
    init() {
        reloadRows()
    }
    
    // MARK:- Rows
    
    private func reloadRows() {
        let sleepTimerRow = Row<BasicTableViewCell>(configure: { [unowned self] cell, _ in
            cell.textLabel?.text = NSLocalizedString("Sleep Timer", comment: "Sleep Timer")
            cell.detailTextLabel?.text = String(describing: self.sleepTimer.description)
        }, selection: { _ in
            
        }, isEnabled: true)
        
        let alarmRow = Row<BasicTableViewCell>(configure: { [unowned self] cell, _ in
            cell.textLabel?.text = NSLocalizedString("Alarm", comment: "Alarm")
            cell.detailTextLabel?.text = self.alarmTime.shortTimeString
        }, selection: { _ in
            
        }, isEnabled: true)
        
        rows = [sleepTimerRow, alarmRow]
    }
}
