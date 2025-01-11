//
//  MachoFramework
//
//  CalendarViewDecolator.swift
//
//  Created by stotic-dev on 2025/01/05
//  Copyright © Macho All rights reserved.
//

import UIKit

final class CalendarViewDecolator: NSObject, UICalendarViewDelegate, Sendable {
    
    private let componentsDecorationDic: [DateComponents: UICalendarView.Decoration]
    
    init(componentsDecorationDic: [DateComponents : UICalendarView.Decoration]) {
        
        self.componentsDecorationDic = componentsDecorationDic
    }
    
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        
        return componentsDecorationDic[dateComponents]
    }
}
