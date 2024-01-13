//
//  DiaryListItemFeature.swift
//  Macho
//
//  Created by 佐藤汰一 on 2024/01/07.
//

import ComposableArchitecture
import Foundation

struct DiaryListItemFeature: Reducer, Sendable {
        
    struct State: Equatable, Identifiable, Sendable {
        
        let id = UUID()
        let title: String
        let message: String
        let date: Date
        let isWin: Bool
    }
    
    enum Action: Sendable {
        
    }
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            
            return .none
        }
    }
}
