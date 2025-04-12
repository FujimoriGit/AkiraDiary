//
//  MachoFramework
//
//  ColorUtilExtension.swift
//
//  Created by stotic-dev on 2025/01/21
//  Copyright © Macho All rights reserved.
//

import SwiftUI

extension Color {
    
    static func getWinOrLoseColorByIsAchieved(_ isAchieved: Bool) -> Color {
        
        return Color(asset: isAchieved ? CustomColor.winColor : CustomColor.loseColor)
    }
}
