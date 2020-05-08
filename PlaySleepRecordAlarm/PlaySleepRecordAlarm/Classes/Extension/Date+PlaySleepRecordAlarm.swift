//
//  Date+PlaySleepRecordAlarm.swift
//  PlaySleepRecordAlarm
//
//  Created by Vlad Zhaglevskiy on 07.05.2020.
//  Copyright © 2020 None. All rights reserved.
//

import Foundation

extension Date {
    static func fromComponents(year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, in calendar: Calendar = .current) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        
        return calendar.date(from: components)
    }
}

extension Date {
    func string(with formatter: DateFormatter) -> String {
        return formatter.string(from: self)
    }
    
    var shortTimeString: String {
        return string(with: .timeShortFormatter)
    }
    
    var compactString: String {
        return string(with: .compactFormatter)
    }
}
