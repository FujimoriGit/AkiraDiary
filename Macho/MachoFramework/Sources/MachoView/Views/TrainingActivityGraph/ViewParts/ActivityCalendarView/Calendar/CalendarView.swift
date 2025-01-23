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
        
        return CalendarViewDecorator (componentsDecorationDic: [:])
    }
    
    func updateUIView(_ uiView: UICalendarView, context: Context) {
                
        // update available date range
        
        // 変更後の表示可能期間が現在の表示日から外れている場合、そのまま表示可能期間を設定するとクラッシュするため
        // 現在の表示日を変更後の表示可能期間内に収まるように更新する
        if let visibleDate = calendar.date(from: uiView.visibleDateComponents),
           !interval.contains(visibleDate) {
            
            let newVisibleDate = visibleDate < interval.start ? interval.start : interval.end
            
            // 変更後の表示日が現在の表示可能期間外の場合、そのまま表示日を設定するとクラッシュするため、
            // 現在の表示可能期間を変更前の表示期間〜変更後の表示期間となるようにする
            if !uiView.availableDateRange.contains(newVisibleDate) {
                
                let start = min(visibleDate, newVisibleDate)
                let end = max(visibleDate, newVisibleDate)
                uiView.availableDateRange = .init(start: start, end: end)
            }
            uiView.visibleDateComponents = calendar.dateComponents([.year, .month], from: newVisibleDate)
        }
        
        uiView.availableDateRange = interval
        
        // update visible date
        
        if let selectVisibleDate = calendar.date(from: initialDate),
           interval.contains(selectVisibleDate) {
            
            uiView.setVisibleDateComponents(initialDate, animated: true)
        }
        
        // update locale
        
        uiView.locale = locale
        
        // update timezone
        
        uiView.timeZone = timeZone
        
        // update decorator
        
        let decorator = context.coordinator
        decorator.componentsDecorationDic = decorationDic
        uiView.delegate = decorator
        uiView.reloadDecorations(forDateComponents: decorationDic.keys.map(\.self), animated: true)
    }
}
