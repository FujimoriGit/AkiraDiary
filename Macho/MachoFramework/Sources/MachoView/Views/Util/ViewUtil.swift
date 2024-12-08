//
//  ViewUtil.swift
//
//  
//  Created by Daiki Fujimori on 2024/04/07
//

import SwiftUI

struct ViewUtil {
    
    static func calcWidth(size: CGSize, horizontalPadding: CGFloat) -> CGFloat {
        
        guard size.width > (horizontalPadding * 2) else { return size.width }
        
        return abs(size.width - (horizontalPadding * 2))
    }
}
