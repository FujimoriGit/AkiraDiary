//
//  FrameButtonStyle.swift
//  Macho
//
//  Created by 佐藤汰一 on 2024/03/02.
//

import SwiftUI

struct FrameButtonStyle: ButtonStyle {
    
    private let foregroundColor: Color
    private let backgroundColor: Color
    private let pressedBackgroundColor: Color
    private let frameWidth: CGFloat
    private let cornerRadius: CGFloat
    
    init(foregroundColor: Color,
         backgroundColor: Color,
         pressedBackgroundColor: Color,
         frameWidth: CGFloat,
         cornerRadius: CGFloat) {
        
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.pressedBackgroundColor = pressedBackgroundColor
        self.frameWidth = frameWidth
        self.cornerRadius = cornerRadius
    }
    
    func makeBody(configuration: Configuration) -> some View {
        
        configuration.label
            .foregroundStyle(foregroundColor)
            .background(configuration.isPressed ? pressedBackgroundColor : backgroundColor)
            .borderModifier(cornerRadius: cornerRadius,
                            borderColor: foregroundColor,
                            frameWidth: frameWidth)
    }
}

// MARK: - Button extension

extension Button {
    
    /// FrameStyleのボタンにする
    /// - Parameters:
    ///   - foregroundColor: ボタンラベルのコンテンツとborderの色
    ///   - backgroundColor: ボタンの背景色
    ///   - pressedBackgroundColor: ボタンのハイライト時の背景色
    ///   - frameWidth: borderの長さ
    ///   - cornerRadius: ボタンの角の丸み
    func frameButtonStyle(foregroundColor: Color = Color(asset: CustomColor.frameButtonForegroundColor),
                          backgroundColor: Color = Color(asset: CustomColor.frameButtonBackgroundColor),
                          pressedBackgroundColor: Color = Color(asset: CustomColor.focusButtonBackgroundColor),
                          frameWidth: CGFloat = 1,
                          cornerRadius: CGFloat = 4) -> some View {
        
        self.buttonStyle(FrameButtonStyle(foregroundColor: foregroundColor,
                                          backgroundColor: backgroundColor,
                                          pressedBackgroundColor: pressedBackgroundColor,
                                          frameWidth: frameWidth,
                                          cornerRadius: cornerRadius))
    }
}

extension Menu {
    
    /// FrameStyleのボタンにする
    /// - Parameters:
    ///   - foregroundColor: ボタンラベルのコンテンツとborderの色
    ///   - backgroundColor: ボタンの背景色
    ///   - pressedBackgroundColor: ボタンのハイライト時の背景色
    ///   - frameWidth: borderの長さ
    ///   - cornerRadius: ボタンの角の丸み
    func frameButtonStyle(foregroundColor: Color = Color(asset: CustomColor.frameButtonForegroundColor),
                          backgroundColor: Color = Color(asset: CustomColor.frameButtonBackgroundColor),
                          pressedBackgroundColor: Color = Color(asset: CustomColor.focusButtonBackgroundColor),
                          frameWidth: CGFloat = 1,
                          cornerRadius: CGFloat = 4) -> some View {
        
        self.buttonStyle(FrameButtonStyle(foregroundColor: foregroundColor,
                                          backgroundColor: backgroundColor,
                                          pressedBackgroundColor: pressedBackgroundColor,
                                          frameWidth: frameWidth,
                                          cornerRadius: cornerRadius))
    }
}
