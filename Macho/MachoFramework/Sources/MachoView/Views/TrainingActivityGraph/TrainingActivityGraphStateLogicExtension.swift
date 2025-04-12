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
        calendar.displayInterval = activityPeriod.getDateInterval(activityStartPeriod)
    }
    
    mutating func updateStartPeriodDate(_ date: Date) {
        
        activityStartPeriod = date
        calendar.displayInterval = activityPeriod.getDateInterval(activityStartPeriod)
    }
    
    mutating func updatePeriod(_ period: ActivityPeriod) {
        
        activityPeriod = period
        calendar.displayInterval = activityPeriod.getDateInterval(activityStartPeriod)
    }
    
    mutating func updateActivityResults(_ diaries: [DiaryData]) {
        
        activityResultList = .init(
            diaries,
            periodFilter: .init(
                startPeriodDate: activityStartPeriod,
                period: activityPeriod
            ),
            trainingTypeFilter: .init(trainingTypeList: targetTrainingTypeList)
        )
        calendar.decorationSources = activityResultList.buildCalendarDecorator()
    }
}
