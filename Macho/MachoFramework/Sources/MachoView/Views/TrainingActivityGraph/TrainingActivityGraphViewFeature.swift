//
//  TrainingActivityGraphViewFeature.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/24.
//

import ComposableArchitecture

@Reducer
struct TrainingActivityGraphViewFeature {    
    
    // MARK: - state definition
    
    struct State: Equatable, Sendable {}
    
    // MARK: - action definition
    
    enum Action: Equatable, Sendable {}
    
    // MARK: - reduce definition
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            return .none
        }
    }
}
