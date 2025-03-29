//
//  MachoFramework
//
//  CalendarView.swift
//
//  Created by stotic-dev on 2025/01/05
//  Copyright © Macho All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import UIKit

struct CalendarView: UIViewRepresentable {
    
    @Environment(\.calendar)
    private var calendar
    @Environment(\.locale)
    private var locale
    @Environment(\.timeZone)
    private var timeZone
    
    private let initialDate: DateComponents
    private let interval: DateInterval
    private let decorationDic: [DateComponents: ActivityResultDecoration]
    private let onSelectDay: (DateComponents?) -> Void
    
    /// カレンダーコンポーネント
    /// - Parameters:
    ///   - initialDate: 最初に表示する日付
    ///   - interval: 表示する期間
    ///   - decorator: カレンダーの装飾
    ///   - onSelectDay: 日付タップ時のハンドラ
    init(initialDate: DateComponents,
         interval: DateInterval,
         decorationDic: [DateComponents: ActivityResultDecoration] = [:],
         onSelectDay: @escaping (DateComponents?) -> Void = { _ in }) {
        
        self.initialDate = initialDate
        self.interval = interval
        self.decorationDic = decorationDic
        self.onSelectDay = onSelectDay
    }
    
    // swiftlint:disable:next unused_parameter
    func makeUIView(context: Context) -> UICalendarView {
        
        return SingleSelectCalendarView(selectHandler: onSelectDay)
    }
    
    func makeCoordinator() -> CalendarViewDecorator {
        
        return CalendarViewDecorator(componentsDecorationDic: [:])
    }
    
    func updateUIView(_ uiView: UICalendarView, context: Context) {
                
        // update available date range and visible date
        
        let selectionRange = CalendarSelectionRange(
            visibleComponents: uiView.visibleDateComponents,
            availableDateRange: uiView.availableDateRange,
            calendar: calendar
        )
        updateSelectionRange(
            uiView,
            events: selectionRange.makeSelectionRangeUpdateEvents(interval, initialDate)
        )
        
        // update locale
        
        uiView.locale = locale
        
        // update timezone
        
        uiView.timeZone = timeZone
        
        // update decorator
        
        let decorator = context.coordinator
        decorator.componentsDecorationDic = decorationDic
        uiView.delegate = decorator
        uiView.reloadDecorations(forDateComponents: decorationDic.keys.map(\.self),
                                 animated: true)
    }
}

private extension CalendarView {
    
    func updateSelectionRange(_ calendar: UICalendarView,
                              events: [CalendarSelectionRange.UpdateEvent]) {
        
        for event in events {
            
            switch event {
                
            case .visibleDateComponents(let value):
                calendar.visibleDateComponents = value
                
            case .visibleDateComponentsWithAnimation(let value):
                calendar.setVisibleDateComponents(value, animated: true)
                
            case .availableDateRange(let value):
                calendar.availableDateRange = value
            }
        }
    }
}
