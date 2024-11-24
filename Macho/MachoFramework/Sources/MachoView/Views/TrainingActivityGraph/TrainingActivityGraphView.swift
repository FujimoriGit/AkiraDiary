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
    
    @Bindable private var store: StoreOf<TrainingActivityGraphViewFeature>
    
    // MARK: - initialize method
    
    init(store: StoreOf<TrainingActivityGraphViewFeature>) {
        
        self.store = store
    }
    
    // MARK: - view body
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

// MARK: - preview

#Preview {
    TrainingActivityGraphView(store: Store(initialState: .init(),
                                           reducer: { TrainingActivityGraphViewFeature() }))
}
