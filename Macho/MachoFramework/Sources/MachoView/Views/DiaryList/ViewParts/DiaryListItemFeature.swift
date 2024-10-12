//
//  DiaryListItemFeature.swift
//  Macho
//
//  Created by 佐藤汰一 on 2024/01/07.
//

import ComposableArchitecture
import Foundation

@Reducer
struct DiaryListItemFeature: Sendable {
    
    @ObservableState
    struct State: Equatable, Identifiable, Sendable {
        
        init(id: UUID = UUID(),
             title: String,
             message: String,
             date: Date,
             isWin: Bool,
             trainingList: [UUID],
             tagList: [UUID]) {
            
            self.id = id
            self.title = title
            self.message = message
            self.date = date
            self.isWin = isWin
            self.trainingList = trainingList
            self.tagList = tagList
        }
        
        init(_ entity: DiaryData) {
            
            id = entity.id
            title = entity.title
            message = entity.mainText
            date = entity.date
            isWin = entity.goals.isEmpty ? false : !entity.goals.contains { !($0.isSuccess ?? false) }
            trainingList = entity.goals.compactMap { $0.goalType?.id }
            tagList = entity.tags.map(\.id)
        }
        
        let id: UUID
        /// 日記のタイトル
        let title: String
        /// 日記のメッセージ
        let message: String
        /// 日記の作成日付
        let date: Date
        /// 目標達成したかどうか
        let isWin: Bool
        /// 日記に登録したトレーニング種別のID
        let trainingList: [UUID]
        /// 日記に登録したタグのID
        let tagList: [UUID]
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
        
        Reduce { _, action in
            
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
