//
//  MachoFramework
//
//  DetailDayOfActivityFeature.swift
//
//  Created by stotic-dev on 2025/01/21
//  Copyright © Macho All rights reserved.
//

import ComposableArchitecture
import Foundation

@Reducer
struct DetailDayOfActivityFeature: PopUpableContentFeature {
    
    @ObservableState
    struct State: Equatable {
        
        /// 選択されている日付の文字列
        let targetDayStr: String
        /// 選択されている日付に含まれるアクティビティ(日記の結果)
        let activities: [ActivityResultOfDay.ActivityEvent]
        /// 選択されている日付のアクティビティ全て達成できているか
        let isAchieved: Bool
    }
    
    enum Action: PopUpableContentAction {
        
        // MARK: event action
        
        /// 閉じるボタン押下時
        case tappedCloseButton
        
        // MARK: delegate action
        
        /// デリゲートアクション
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            
            /// 画面非表示
            case willDisapear
            /// アクティビティの領域を押下した時
            case tappedActivityArea(diaryId: UUID)
        }
        
        static var willDismissAction: DetailDayOfActivityFeature.Action {
            
            return .delegate(.willDisapear)
        }
    }
    
    var body: some ReducerOf<Self> {
        
        Reduce { _, action in
            
            switch action {
                
            case .tappedCloseButton:
                return .send(.delegate(.willDisapear))
                
            case .delegate:
                return .none
            }
        }
    }
}

extension DetailDayOfActivityFeature.State {
    
    init(_ result: ActivityResultOfDay) {
        
        targetDayStr = result.targetDate.formatted(.date)
        activities = result.activities
        isAchieved = result.isAchieved
    }
}
