//
//  MachoFramework
//
//  ActivityResultDecoration.swift
//
//  Created by stotic-dev on 2025/01/13
//  Copyright © Macho All rights reserved.
//

import UIKit

struct ActivityResultDecoration: CalendarViewDecoratable {
    
    private let activityResult: ActivityResultOfDay
    
    init(activityResult: ActivityResultOfDay) {
        
        self.activityResult = activityResult
    }
    
    func getDecoration() -> UICalendarView.Decoration {
        
        let systemImageName = activityResult.isAchieved ? "checkmark" : "xmark"
        let imageColor = activityResult.isAchieved ?
        UIColor(asset: CustomColor.winColor) :
        UIColor(asset: CustomColor.loseColor)
        return .image(UIImage(systemName: systemImageName), color: imageColor)
    }
}

// MARK: - for factory method extension

extension CalendarViewDecorator where Decoration == ActivityResultDecoration {
    
    static func create(activityResults: ActivityResults) -> some CalendarViewDecorator {
        
        return CalendarViewDecorator(componentsDecorationDic: activityResults.buildCalendarDecorator())
    }
}
