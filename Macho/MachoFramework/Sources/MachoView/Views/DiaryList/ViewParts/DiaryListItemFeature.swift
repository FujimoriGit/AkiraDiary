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
        /// 日記のタイトル
        let title: String
        /// 日記のメッセージ
        let message: String
        /// 日記の作成日付
        let date: Date
        /// 目標達成したかどうか
        let isWin: Bool
        /// 日記に登録したトレーニング種別
        let trainingList: [String]
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
                logger.info("tappedDiaryItem")
                
            case .deleteItemSwipeAction:
                logger.info("deleteItemSwipeAction")
                
            case .editItemSwipeAction:
                logger.info("editItemSwipeAction")
            }
            return .none
        }
    }
}
