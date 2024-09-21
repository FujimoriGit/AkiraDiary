//
//  ViewUtil.swift
//
//  
//  Created by Daiki Fujimori on 2024/04/07
//  
//

import SwiftUI

struct ViewUtil {
    
    static func calcWidth(size: CGSize, horizontalPadding: CGFloat) -> CGFloat {
        
        size.width - (horizontalPadding * 2)
    }
}
