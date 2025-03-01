//
//  DiaryListItemFeature.swift
//  Macho
//
//  Created by 佐藤汰一 on 2024/01/07.
//

import ComposableArchitecture
import Foundation
import MachoCore

@Reducer
struct DiaryListItemFeature: Sendable {
    
    @ObservableState
    struct State: Equatable, Identifiable, Sendable {
        
        let entity: ConcreteDiaryData
        
        var id: UUID { entity.id }
        /// 日記のタイトル
        var title: String { entity.title }
        /// 日記のメッセージ
        var message: String { entity.mainText }
        /// 日記の作成日付
        var date: Date { entity.date }
        /// 目標達成したかどうか
        var isWin: Bool { !entity.goals.contains { !$0.isAchieved } } // TODO: ドメインクラスにロジックを切り出したい
        /// 日記に登録したトレーニング種別のID
        var trainingList: [UUID] { entity.goals.compactMap { $0.trainingType?.id } }
        /// 日記に登録したタグのID
        var tagList: [UUID] { entity.tags.map(\.id) }
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
