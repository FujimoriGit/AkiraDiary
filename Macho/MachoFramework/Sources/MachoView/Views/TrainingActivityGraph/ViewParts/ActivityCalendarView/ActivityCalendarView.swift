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
        CalendarView(store: store.scope(state: \.calendarView, action: \.calendarView),
                     initialDate: store.initialDisplayDate,
                     interval: store.displayInterval,
                     decolator: store.calendarDecorator)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private extension ActivityCalendarView {
}

#Preview {
    let interval = DateInterval(start: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date(),
                                end: Date())
    ActivityCalendarView(store: Store(initialState: .init(displayInterval: interval)) {
        ActivityCalendarFeature()
    })
    .frame(height: 300)
    .padding(.horizontal, 16)
    .environment(\.locale, Locale(identifier: "ja_JP"))
}
