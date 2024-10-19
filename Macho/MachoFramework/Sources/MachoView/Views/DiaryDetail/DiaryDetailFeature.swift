//
//  DiaryDetailFeature.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/10/19.
//

import ComposableArchitecture
import RealmHelper

@Reducer
struct DiaryDetailFeature {
        
    struct State: Equatable {
        
        static func == (lhs: DiaryDetailFeature.State, rhs: DiaryDetailFeature.State) -> Bool {
            
            return lhs.diary.id == rhs.diary.id
        }
        
        var diary: DiaryEntity
    }
    
    enum Action {
        
        // MARK: Event Action
        
        /// 画面表示時
        case onAppear
        /// 画面非表示時
        case onDisappear
        
        // MARK: Effect Action
        
        /// 日記の取得副作用
        case didReceivedDiary(DiaryEntity)
    }
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            
            switch action {
                
            case .onAppear:
                return .none
                
            case .onDisappear:
                return .none
                
            case .didReceivedDiary(let diary):
                return .none
            }
        }
    }
}
