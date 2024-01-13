//
//  DiaryListFeature.swift
//  Macho
//
//  Created by 佐藤汰一 on 2024/01/07.
//

import ComposableArchitecture
import Foundation

struct DiaryListFeature: Reducer {
    
    struct State: Equatable {
        
        var diaries = IdentifiedArrayOf<DiaryListItemFeature.State>()
    }
    
    enum Action: Sendable {
        
        case diaries(id: DiaryListItemFeature.State.ID, action: DiaryListItemFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            
            switch action {
                
            case .diaries:
                return .none
            }
        }
        .forEach(\.diaries, action: /Action.diaries(id:action:)) {
            DiaryListItemFeature()
        }
    }
}
