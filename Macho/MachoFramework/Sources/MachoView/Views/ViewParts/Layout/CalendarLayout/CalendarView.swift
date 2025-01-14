//
//  MachoFramework
//
//  CalendarView.swift
//
//  Created by stotic-dev on 2025/01/05
//  Copyright © Macho All rights reserved.
//

import ComposableArchitecture
import UIKit
import SwiftUI

struct CalendarView: UIViewRepresentable {
    
    @Environment(\.locale) private var locale
    
    private let initialDate: DateComponents
    private let interval: DateInterval
    private let decorator: UICalendarViewDelegate?
    private let onSelectDay: (DateComponents?) -> Void
    
    /// カレンダーコンポーネント
    /// - Parameters:
    ///   - initialDate: 最初に表示する日付
    ///   - interval: 表示する期間
    ///   - decorator: カレンダーの装飾
    ///   - onSelectDay: 日付タップ時のハンドラ
    init(initialDate: DateComponents,
         interval: DateInterval,
         decorator: UICalendarViewDelegate? = nil,
         onSelectDay: @escaping (DateComponents?) -> Void = { _ in }) {
        
        self.initialDate = initialDate
        self.interval = interval
        self.decorator = decorator
        self.onSelectDay = onSelectDay
    }
    
    func makeUIView(context: Context) -> UICalendarView {
        
        return SingleSelectCalendarView(selectHandler: onSelectDay)
    }

    func updateUIView(_ uiView: UICalendarView, context: Context) {
        
        uiView.visibleDateComponents = initialDate
        uiView.availableDateRange = interval
        uiView.locale = locale
        uiView.delegate = decorator
    }
}
