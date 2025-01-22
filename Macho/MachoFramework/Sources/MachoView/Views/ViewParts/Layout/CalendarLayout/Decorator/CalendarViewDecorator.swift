//
//  MachoFramework
//
//  CalendarViewDecolator.swift
//
//  Created by stotic-dev on 2025/01/05
//  Copyright © Macho All rights reserved.
//

import UIKit

final class CalendarViewDecorator<Decoration: CalendarViewDecoratable>: NSObject, UICalendarViewDelegate, Sendable {
    
    // MARK: - private property
    
    private let componentsDecorationDic: [DateComponents: Decoration]
    
    // MARK: - initialize method
    
    init(componentsDecorationDic: [DateComponents: Decoration]) {
        
        self.componentsDecorationDic = componentsDecorationDic
    }
    
    // MARK: - factory method
    
    static func getInitial<T: CalendarViewDecoratable>() -> CalendarViewDecorator<T> {
        
        return CalendarViewDecorator<T>(componentsDecorationDic: [:])
    }
    
    // MARK: - public method
    
    // swiftlint:disable:next unused_parameter
    func calendarView(_ calendarView: UICalendarView,
                      decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        
        guard let targetKey = componentsDecorationDic.keys.first(where: { isSameDay($0, rhs: dateComponents) }) else { return nil }
        return componentsDecorationDic[targetKey]?.getDecoration()
    }
    
    /// テスト時に比較を想定したオーバーライド
    ///
    /// - Returns: デコレーションの内容を比較した結果を返す
    override func isEqual(_ object: Any?) -> Bool {
        
        guard let decorator = object as? Self else { return false }
        return decorator.componentsDecorationDic == componentsDecorationDic
    }
}

private extension CalendarViewDecorator {
    
    /// 年月日を比較する
    func isSameDay(_ lhs: DateComponents, rhs: DateComponents) -> Bool {
        
        return lhs.year == rhs.year && lhs.month == rhs.month && lhs.day == rhs.day
    }
}
