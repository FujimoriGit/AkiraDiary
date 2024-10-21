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
    
    // MARK: - State
        
    @ObservableState
    struct State: Equatable {
        
        static func == (lhs: DiaryDetailFeature.State, rhs: DiaryDetailFeature.State) -> Bool {
            
            return lhs.diary.id == rhs.diary.id
        }
        
        var diary: DiaryEntity
        
        var title: String { diary.title }
        var message: String { diary.mainText }
        var tags: [TrainingTagEntity] { diary.tags }
        var totalResult: TotalTrainingResult { TotalTrainingResult(diary) }
        var trainings: [TrainingTypeResult]
    }
    
    // MARK: - Action
    
    enum Action {
        
        // MARK: Event Action
        
        /// 画面表示時
        case onAppear
        /// 画面非表示時
        case onDisappear
        /// 編集ボタン押下時
        case tappedEditButton
        /// さらに表示ボタン押下時
        case tappedShowMoreMessageButton
        
        // MARK: Effect Action
        
        /// 日記の取得副作用
        case didReceivedDiary(DiaryEntity)
    }
    
    // MARK: - Dependency
    
    @Dependency var diaryListItemApi: DiaryListItemClient
    
    // MARK: - Reducer
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            
            switch action {
                
            case .onAppear:
                return .none
                
            case .onDisappear:
                return .none
                
            case .tappedEditButton:
                return .none
                
            case .tappedShowMoreMessageButton:
                return .none
                
            case .didReceivedDiary(let diary):
                return .none
            }
        }
    }
}
