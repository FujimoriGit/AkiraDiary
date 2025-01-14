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
    
    // MARK: layout property
    
    private let dayOfWeekHorizontalSpace: CGFloat = 14
    
    // MARK: - initialize method
    
    init(store: StoreOf<ActivityCalendarFeature>) {
        
        self.store = store
    }
    
    // MARK: - view body
    
    var body: some View {
        CalendarView(initialDate: store.initialDisplayDate,
                     interval: store.displayInterval,
                     decorator: store.calendarDecorator) {
            store.send(.delegate(.selectedDay($0)))
        }
                     .frame(maxWidth: .infinity,
                            maxHeight: .infinity)
    }
}

// MARK: - preview definition

#Preview {
    let interval = DateInterval(start: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date(),
                                end: Date())
    let activityResults = ActivityResults(resultList: [
        ActivityResultOfDay(targetDate: interval.start,
                            activities: [.init(id: UUID(), title: "Test1", isAchieved: true)]),
        ActivityResultOfDay(targetDate: Calendar.current.date(byAdding: .day, value: 1, to: interval.start) ?? .now,
                            activities: [.init(id: UUID(), title: "Test2", isAchieved: false)])
    ])
    
    ActivityCalendarView(store: Store(initialState: .init(
        displayInterval: interval,
        calendarDecorator: .create(activityResults: activityResults)
    )) {
        ActivityCalendarFeature()
    })
    .padding(.horizontal, 16)
    .environment(\.locale, Locale(identifier: "ja_JP"))
}
