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
    
    mutating func updatePeriodFilter(_ filter: ActivityPeriodFilter) {
        
        activityStartPeriod = filter.startPeriodDate
        activityPeriod = filter.period
        updateDisplayInterval(startPeriod: activityStartPeriod, period: activityPeriod)
    }
    
    mutating func updateStartPeriodDate(_ date: Date) {
        
        activityStartPeriod = date
        updateDisplayInterval(startPeriod: date, period: activityPeriod)
    }
    
    mutating func updatePeriod(_ period: ActivityPeriod) {
        
        activityPeriod = period
        updateDisplayInterval(startPeriod: activityStartPeriod, period: period)
    }
    
    mutating func updateActivityResults(_ diaries: [DiaryData]) {
        
        activityResultList = .init(diaries,
                                   periodFilter: periodFilter,
                                   trainingTypeFilter: trainingTypeFilter)
        calendar.decorationSources = activityResultList.buildCalendarDecorator()
    }
}

private extension TrainingActivityGraphFeature.State {
    
    var periodFilter: ActivityPeriodFilter { .init(startPeriodDate: activityStartPeriod,
                                                   period: activityPeriod) }
    
    var trainingTypeFilter: ActivityGraphTrainingTypeFilter {
        
        return .init(trainingTypeList: targetTrainingTypeList)
    }
    
    mutating func updateDisplayInterval(startPeriod: Date, period: ActivityPeriod) {
        
        guard let displayInterval = period.getDateInterval(startPeriod) else {
            
            return
        }
        calendar.displayInterval = displayInterval
    }
}
