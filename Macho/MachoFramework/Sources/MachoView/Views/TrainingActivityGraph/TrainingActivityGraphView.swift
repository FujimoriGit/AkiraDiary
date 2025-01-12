//
//  TrainingActivityGraphView.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/24.
//

import ComposableArchitecture
import SwiftUI

struct TrainingActivityGraphView: View {
    
    // MARK: - private property
    
    @Bindable private var store: StoreOf<TrainingActivityGraphFeature>
    
    // MARK: - initialize method
    
    init(store: StoreOf<TrainingActivityGraphFeature>) {
        
        self.store = store
    }
    
    // MARK: - view body
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

// MARK: - preview

#Preview {
    TrainingActivityGraphView(
        store: Store(initialState: .getDefaultState(),
                     reducer: { TrainingActivityGraphFeature() })
    )
}
