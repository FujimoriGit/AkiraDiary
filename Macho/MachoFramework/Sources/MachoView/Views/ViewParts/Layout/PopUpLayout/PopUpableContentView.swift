//
//  PopUpableContentView.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/12/11.
//

import ComposableArchitecture
import SwiftUI

protocol PopUpableContentView<Feature>: View {
    
    associatedtype Feature: PopUpableContentFeature
    
    init(store: some StoreOf<Feature>)
}
