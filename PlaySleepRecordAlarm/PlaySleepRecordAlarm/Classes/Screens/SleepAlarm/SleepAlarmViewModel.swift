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

final class SleepAlarmViewModelImp: SleepAlarmViewModel {
    
    // MARK:- Properties
    
    private(set) var rows: [RowDescription] = []
    
    // MARK:- Initalization
    
    init() {
        reloadRows()
    }
    
    // MARK:- Rows
    
    private func reloadRows() {
        let sleepTimerRow = Row<BasicTableViewCell>(configure: { cell, _ in
            cell.textLabel?.text = NSLocalizedString("Sleep Timer", comment: "Sleep Timer")
            cell.detailTextLabel?.text = "20 min"
        }, selection: { _ in
            
        }, isEnabled: true)
        
        let alarmRow = Row<BasicTableViewCell>(configure: { cell, _ in
            cell.textLabel?.text = NSLocalizedString("Alarm", comment: "Alarm")
            cell.detailTextLabel?.text = "08:30 am"
        }, selection: { _ in
            
        }, isEnabled: true)
        
        rows = [sleepTimerRow, alarmRow]
    }
}
