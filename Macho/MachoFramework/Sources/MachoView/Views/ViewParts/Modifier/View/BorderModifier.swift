//
//  CornerButtonStyle.swift
//  Macho
//
//  Created by 佐藤汰一 on 2024/03/02.
//

import SwiftUI

struct BorderModifier: ViewModifier {
    
    private let cornerRadius: CGFloat
    private let borderColor: Color
    private let frameWidth: CGFloat
    
    init(cornerRadius: CGFloat,
         borderColor: Color,
         frameWidth: CGFloat) {
        
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.frameWidth = frameWidth
    }
    
    func body(content: Content) -> some View {
        
        content
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: frameWidth)
            }
    }
}

// MARK: - View extension

extension View {
    
    /// Viewのborderに付与するModifier
    /// - Parameters:
    ///   - cornerRadius: 角の丸み（デフォルトでは4）
    ///   - borderColor: boderに色（デフォルトでは透明色）
    ///   - frameWidth: boderの長さ（デフォルトでは0）
    func borderModifier(cornerRadius: CGFloat = 4,
                        borderColor: Color = .clear,
                        frameWidth: CGFloat = 0) -> some View {
        
        self.modifier(BorderModifier(cornerRadius: cornerRadius,
                                     borderColor: borderColor,
                                     frameWidth: frameWidth))
    }
}
