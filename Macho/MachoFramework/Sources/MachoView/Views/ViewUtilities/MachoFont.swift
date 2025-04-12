//
//  MachoFramework
//
//  MachoFont.swift
//
//  Created by stotic-dev on 2025/01/31
//  Copyright © Macho All rights reserved.
//

import SwiftUI

extension Font {
    
    static func macho(_ machoFont: MachoFont) -> Self {
        
        return machoFont.value
    }
    
    enum MachoFont {
        
        case title
        case subTitle
        case description
        
        var value: Font {
            
            switch self {
                
            case .title:
                return .title
                
            case .subTitle:
                return .title3
                
            case .description:
                return .body
            }
        }
    }
}
