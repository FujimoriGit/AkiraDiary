//
//  RootView.swift
//
//
//  Created by 佐藤汰一 on 2024/02/04.
//

import ComposableArchitecture
import SwiftUI

public struct RootView: View {
    
    public init() {}
    
    public var body: some View {
        DiaryListView(store: Store(initialState: DiaryListFeature.State()) { DiaryListFeature()})
    }
}

#Preview {
    RootView()
}
