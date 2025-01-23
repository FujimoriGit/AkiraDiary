//
//  MachoFramework
//
//  TrainingActivityGraphStateLogicExtension.swift
//
//  Created by stotic-dev on 2025/01/21
//  Copyright © Macho All rights reserved.
//

import Foundation

extension TrainingActivityGraphFeature.State {
    
    mutating func updateStartPeriodDate(_ date: Date) {
        
        activityStartPeriod = date
        updateDisplayInterval(startPeriod: date, period: activityPeriod)
    }
    
    mutating func updatePeriod(_ period: ActivityPeriod) {
        
        activityPeriod = period
        updateDisplayInterval(startPeriod: activityStartPeriod, period: period)
    }
    
    mutating func updateActivityResults(_ diaries: [DiaryData]) {
        
        activityResultList = .init(diaries)
        calendar.decorationDic = activityResultList.buildCalendarDecorator()
    }
}

private extension TrainingActivityGraphFeature.State {
    
    mutating func updateDisplayInterval(startPeriod: Date, period: ActivityPeriod) {
        
        guard let displayInterval = period.getDateInterval(startPeriod) else {
            
            assertionFailure("Failed get dateInterval.")
            return
        }
        calendar.displayInterval = displayInterval
    }
}
