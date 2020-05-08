//
//  DateFormatter+PlaySleepRecordAlarm.swift
//  PlaySleepRecordAlarm
//
//  Created by Vlad Zhaglevskiy on 07.05.2020.
//  Copyright © 2020 None. All rights reserved.
//

import Foundation

extension DateFormatter {
    static let timeShortFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        
        return formatter
    }()
    
    static let compactFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy_HH-mm-ss"
        
        return formatter
    }()
}
