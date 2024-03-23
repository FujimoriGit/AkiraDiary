//
//  RefreshableModifier.swift
//  Macho
//
//  Created by 佐藤汰一 on 2024/01/13.
//

import SwiftUI

struct RefreshableModifier: ViewModifier {
    
    let action: @Sendable () async -> Void
    
    func body(content: Content) -> some View {
        
        List {
            HStack { // HStack + Spacerで中央揃え
                Spacer()
                content
                Spacer()
            }
            .listRowSeparator(.hidden) // 罫線非表示
            .listRowInsets(EdgeInsets()) // Insetsを0に
        }
        .refreshable(action: action)
        .listStyle(PlainListStyle()) // ListStyleの変更
    }
}
