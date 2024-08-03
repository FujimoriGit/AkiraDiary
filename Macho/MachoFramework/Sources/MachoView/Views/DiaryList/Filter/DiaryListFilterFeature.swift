//
//  DiaryListFilterFeature.swift
//
//
//  Created by 佐藤汰一 on 2024/07/28.
//

import ComposableArchitecture

@Reducer
struct DiaryListFilterFeature {
    
    struct State: Equatable, Sendable {
        
        
    }
    
    enum Action {
        
        case onAppear
    }
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            return .none
        }
    }
}
