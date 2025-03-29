//
//  MachoFramework
//
//  MachoAccessibilityIdentifier.swift
//
//  Created by stotic-dev on 2025/03/14
//  Copyright © Macho All rights reserved.
//

import SwiftUI

extension View {
    
    func accessibilityId(_ id: MachoAccessibilityIdentifier) -> some View {
        
        return self.accessibilityIdentifier(id.value)
    }
}

enum MachoAccessibilityIdentifier {
    
    case textField(String)
    
    fileprivate var value: String {
        
        switch self {
            
        case .textField(let description):
            return "textField_\(description)"
        }
    }
}
