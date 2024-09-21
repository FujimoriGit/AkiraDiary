//
//  FillButtonStyle.swift
//  Macho
//
//  Created by 佐藤汰一 on 2024/03/02.
//

import SwiftUI

struct FillButtonStyle: ButtonStyle {
    
    private let foregroundColor: Color
    private let backgroundColor: Color
    private let pressedBackgroundColor: Color
    private let cornerRadius: CGFloat
    
    init(foregroundColor: Color,
         backgroundColor: Color,
         pressedBackgroundColor: Color,
         cornerRadius: CGFloat) {
        
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.pressedBackgroundColor = pressedBackgroundColor
        self.cornerRadius = cornerRadius
    }
    
    func makeBody(configuration: Configuration) -> some View {
        
        configuration.label
            .foregroundStyle(foregroundColor)
            .background(configuration.isPressed ? pressedBackgroundColor : backgroundColor)
            .borderModifier(cornerRadius: cornerRadius)
    }
}

// MARK: - Button extension

extension Button {
    
    /// FilStyleのボタンにする
    /// - Parameters:
    ///   - foregroundColor: ボタンラベルのコンテンツの色
    ///   - backgroundColor: ボタンの背景色
    ///   - pressedBackgroundColor: ボタンのハイライト時の背景色
    ///   - cornerRadius: ボタンの角の丸み
    func fillButtonStyle(foregroundColor: Color = Color(asset: CustomColor.fillButtonForegroundColor),
                         backgroundColor: Color = Color(asset: CustomColor.fillButtonBackgroundColor),
                         pressedBackgroundColor: Color = Color(asset: CustomColor.focusButtonBackgroundColor),
                         cornerRadius: CGFloat = 4) -> some View {
        
        self.buttonStyle(FillButtonStyle(foregroundColor: foregroundColor,
                                         backgroundColor: backgroundColor,
                                         pressedBackgroundColor: pressedBackgroundColor,
                                         cornerRadius: cornerRadius))
    }
}

extension Menu {
    
    /// FilStyleのボタンにする
    /// - Parameters:
    ///   - foregroundColor: ボタンラベルのコンテンツの色
    ///   - backgroundColor: ボタンの背景色
    ///   - pressedBackgroundColor: ボタンのハイライト時の背景色
    ///   - cornerRadius: ボタンの角の丸み
    func fillButtonStyle(foregroundColor: Color = Color(asset: CustomColor.fillButtonForegroundColor),
                         backgroundColor: Color = Color(asset: CustomColor.fillButtonBackgroundColor),
                         pressedBackgroundColor: Color = Color(asset: CustomColor.focusButtonBackgroundColor),
                         cornerRadius: CGFloat = 4) -> some View {
        
        let pressedColor = pressedBackgroundColor ?? backgroundColor.opacity(0.5)
        
        return buttonStyle(FillButtonStyle(foregroundColor: foregroundColor,
                                           backgroundColor: backgroundColor,
                                           pressedBackgroundColor: pressedColor,
                                           cornerRadius: cornerRadius))
    }
}
