//
//  MachoFramework
//
//  ActivityCalendarView.swift
//
//  Created by stotic-dev on 2025/01/05
//  Copyright © Macho All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct ActivityCalendarView: View {
    
    // MARK: - private property
    
    // MARK: store
    
    @Bindable private var store: StoreOf<ActivityCalendarFeature>
    
    // MARK: - initialize method
    
    init(store: StoreOf<ActivityCalendarFeature>) {
        
        self.store = store
    }
    
    // MARK: - view body
    
    var body: some View {
        CalendarView(initialDate: store.initialDisplayDate,
                     interval: store.displayInterval,
                     decorationSources: store.decorationSources) {
            store.send(.delegate(.selectedDay($0)))
        }
                     .frame(maxWidth: .infinity,
                            maxHeight: .infinity)
    }
}

// MARK: - preview definition

#Preview {
    
    @Environment(\.calendar)
    @Previewable var calendar
    
    let interval = DateInterval(start: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date(),
                                end: Date())
    let activityResults = ActivityResults(
        [
            .init(id: UUID(),
                  createdAt: interval.start,
                  title: "Test1", mainText: "",
                  goals: [],
                  tags: [],
                  status: .finished(.init(isAchieved: true, endTime: .now))),
            .init(id: UUID(),
                  createdAt: interval.start,
                  title: "Test2", mainText: "",
                  goals: [],
                  tags: [],
                  status: .finished(.init(isAchieved: false, endTime: .now))),
        ],
        periodFilter: .init(startPeriodDate: interval.start,
                            period: .month),
        trainingTypeFilter: .init(selectedIdList: [])
    )
    
    ActivityCalendarView(store: Store(initialState: .init(
        displayInterval: interval,
        decorationSources: activityResults.buildCalendarDecorator()
    )) {
        ActivityCalendarFeature()
    })
    .padding(.horizontal, 16)
    .environment(\.locale, Locale(identifier: "ja_JP"))
}
