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
                     decorationDic: store.decorationDic) {
            store.send(.delegate(.selectedDay($0)))
        }
                     .frame(maxWidth: .infinity,
                            maxHeight: .infinity)
    }
}

// MARK: - preview definition

#Preview {
    
    @Previewable @Environment(\.calendar)
    var calendar
    let interval = DateInterval(start: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date(),
                                end: Date())
    let activityResults = ActivityResults([
        .init(id: UUID(),
              date: interval.start,
              title: "Test1",
              mainText: "",
              goals: [
                .init(id: UUID(),
                      trainingType: .init(id: UUID(), name: ""),
                      goalNumberOfSets: 3,
                      goalSetCount: 3,
                      actualNumberOfSets: 3,
                      actualSetCount: 3)
              ],
              tags: [],
              startTime: nil,
              endTime: nil),
        .init(id: UUID(),
              date: calendar.date(byAdding: .day, value: 1, to: interval.start)!,
              title: "Test2",
              mainText: "",
              goals: [
                .init(id: UUID(),
                      trainingType: .init(id: UUID(), name: ""),
                      goalNumberOfSets: 3,
                      goalSetCount: 3,
                      actualNumberOfSets: 1,
                      actualSetCount: 3)
              ],
              tags: [],
              startTime: nil,
              endTime: nil)
    ])
    
    ActivityCalendarView(store: Store(initialState: .init(
        displayInterval: interval,
        decorationDic: activityResults.buildCalendarDecorator()
    )) {
        ActivityCalendarFeature()
    })
    .padding(.horizontal, 16)
    .environment(\.locale, Locale(identifier: "ja_JP"))
}
