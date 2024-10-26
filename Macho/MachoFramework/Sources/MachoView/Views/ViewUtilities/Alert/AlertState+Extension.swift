//
//  AlertState+Extension.swift
//
//
//  Created by 佐藤汰一 on 2024/06/08.
//

import ComposableArchitecture

extension AlertState {
    
    /// AlertTypeに基づいたAlertStateの生成
    /// - Parameters:
    ///   - type: アラートの種類(アラートのメッセージやボタンの文言が定義されている)
    ///   - firstButtonHandler: 一つ目のボタン(左側)押下時のAction
    ///   - secondButtonHandler: 二つ目のボタン(右側)押下時のAction
    ///   - firstButtonRole: 一つ目のボタンの種別
    ///   - secondButtonRole: 二つ目のボタンの種別
    /// - Returns: AlertState(表示するアラートの情報)
    static func createAlertState(_ type: AlertType,
                                 firstButtonHandler: Action,
                                 secondButtonHandler: Action? = nil,
                                 firstButtonRole: ButtonStateRole? = nil,
                                 secondButtonRole: ButtonStateRole? = nil) -> Self {
        
        return AlertState(title: {
            
            TextState(type.title)
        }, actions: {
            
            ButtonState(role: firstButtonRole,
                        action: firstButtonHandler,
                        label: { TextState(type.firstButtonTitle) })
            if let secondButtonHandler,
               let secondButtonTitle = type.secondButtonTitle {
                
                ButtonState(role: secondButtonRole,
                            action: secondButtonHandler,
                            label: { TextState(secondButtonTitle) })
            }
        }, message: type.message == nil ? nil : {
            
            TextState(type.message ?? "")
        })
    }
    
    /// キャンセルボタンが付いたAlertTypeに基づいたAlertStateの生成
    /// - Parameters:
    ///   - type: アラートの種類(アラートのメッセージやボタンの文言が定義されている)
    ///   - firstButtonHandler: 一つ目のボタン(右側)押下時のAction
    ///   - firstButtonRole: 一つ目のボタンの種別
    /// - Returns: AlertState(表示するアラートの情報)
    /// - Attention: キャンセルボタンは必ず左側に表示される
    static func createAlertStateWithCancel(_ type: AlertType,
                                           firstButtonHandler: Action,
                                           firstButtonRole: ButtonStateRole? = nil) -> Self {
        
        return AlertState(title: {
            
            TextState(type.title)
        }, actions: {
            
            Self.createCancelButton()
            ButtonState(role: firstButtonRole,
                        action: firstButtonHandler,
                        label: { TextState(type.firstButtonTitle) })
        }, message: type.message == nil ? nil : {
            
            TextState(type.message ?? "")
        })
    }
}

private extension AlertState {
    
    static func createCancelButton() -> ButtonState<Action> {
        
        return ButtonState(role: .cancel, label: { TextState("Cancel") })
    }
}
