//
//  MachoFramework
//
//  CalendarViewDecolator.swift
//
//  Created by stotic-dev on 2025/01/05
//  Copyright © Macho All rights reserved.
//

import UIKit

final class CalendarViewDecorator: NSObject, UICalendarViewDelegate {
    
    // MARK: - public property
    
    var componentsDecorationDic: [DateComponents: ActivityResultDecoration]
    
    // MARK: - initialize method
    
    init(componentsDecorationDic: [DateComponents: ActivityResultDecoration]) {
        
        self.componentsDecorationDic = componentsDecorationDic
    }
    
    // MARK: - public method
    
    // swiftlint:disable:next unused_parameter
    func calendarView(_ calendarView: UICalendarView,
                      decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        
        guard let targetKey = componentsDecorationDic.keys.first(where: {
            
            dateComponents.isMatchDate($0)
        }),
              let decorationInfo = componentsDecorationDic[targetKey] else { return nil }
        return getDecoration(decorationInfo)
    }
}

private extension CalendarViewDecorator {
    
    func getDecoration(_ decorationInfo: ActivityResultDecoration) -> UICalendarView.Decoration {
        
        let systemImageName = decorationInfo.isAchievedOfDay ? "checkmark" : "xmark"
        let imageColor = decorationInfo.isAchievedOfDay ?
        UIColor(asset: CustomColor.winColor) :
        UIColor(asset: CustomColor.loseColor)
        return .image(UIImage(systemName: systemImageName), color: imageColor)
    }
}
