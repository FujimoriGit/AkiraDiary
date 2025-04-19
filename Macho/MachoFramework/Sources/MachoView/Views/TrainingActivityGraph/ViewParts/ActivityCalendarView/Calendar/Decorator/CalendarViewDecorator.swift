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
    
    var componentsDecorationSources: [ActivityResultDecorationSource]
    
    // MARK: - initialize method
    
    init(_ componentsDecorationSources: [ActivityResultDecorationSource]) {
        
        self.componentsDecorationSources = componentsDecorationSources
    }
    
    // MARK: - public method
    
    // swiftlint:disable:next unused_parameter
    func calendarView(_ calendarView: UICalendarView,
                      decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        
        guard let decorationInfo = componentsDecorationSources.first(where: {
            
            dateComponents.isMatchDate($0.targetDay)
        }) else { return nil }
        return getDecoration(decorationInfo)
    }
}

private extension CalendarViewDecorator {
    
    func getDecoration(_ decorationInfo: ActivityResultDecorationSource) -> UICalendarView.Decoration {
        
        let systemImageName = decorationInfo.isAchievedOfDay ? "checkmark" : "xmark"
        let imageColor = decorationInfo.isAchievedOfDay ?
        UIColor(asset: CustomColor.winColor) :
        UIColor(asset: CustomColor.loseColor)
        return .image(UIImage(systemName: systemImageName), color: imageColor)
    }
}
