//
//  MachoFramework
//
//  ActivityPeriodFilter.swift
//
//  Created by stotic-dev on 2025/01/23
//  Copyright © Macho All rights reserved.
//

import Foundation

struct ActivityPeriodFilter {
    
    let startPeriodDate: Date
    let period: ActivityPeriod
    
    func isMatch(_ diary: Diary) -> Bool {
        
        return period.getDateInterval(startPeriodDate).contains(diary.createdAt)
    }
}

extension ActivityPeriodFilter {
    
    init?(timestamp: TimeInterval, period: Int) {
        
        startPeriodDate = Date(timeIntervalSince1970: timestamp)
        guard let period = ActivityPeriod(rawValue: period) else {
            
            assertionFailure("Invalid activity period value: \(period)")
            return nil
        }
        self.period = period
    }
}
