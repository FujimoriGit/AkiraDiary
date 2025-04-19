//
//  MachoFramework
//
//  Space.swift
//
//  Created by stotic-dev on 2025/01/31
//  Copyright © Macho All rights reserved.
//

import Foundation

extension CGFloat {
    
    static func space(_ type: Space) -> Self {
        
        return type.rawValue
    }
    
    enum Space: CGFloat {
        
        case small = 8
        case medium = 16
        case large = 24
    }
}
