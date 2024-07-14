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
        
        /// アイテムをタップ
        case tappedDiaryItem
        /// アイテム削除のスワイプアクション
        case deleteItemSwipeAction
        /// アイテム編集のスワイプアクション
        case editItemSwipeAction
    }
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            switch action {
                
            case .tappedDiaryItem:
                print("tappedDiaryItem")
            case .deleteItemSwipeAction:
                print("deleteItemSwipeAction")
            case .editItemSwipeAction:
                print("editItemSwipeAction")
            }
            return .none
        }
    }
}
