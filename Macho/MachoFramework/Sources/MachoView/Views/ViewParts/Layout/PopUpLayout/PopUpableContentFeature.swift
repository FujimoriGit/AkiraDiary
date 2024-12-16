//
//  PopUpableContentFeature.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/12/11.
//

import ComposableArchitecture

protocol PopUpableContentFeature: Reducer where State: Equatable & Sendable, Action: PopUpableContentAction {
    
    init()
}

protocol PopUpableContentAction: Equatable, Sendable {
    
    static var willDismissAction: Self { get }
}
