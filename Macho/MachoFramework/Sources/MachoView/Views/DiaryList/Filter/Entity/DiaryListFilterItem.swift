//
//  DiaryListFilterItem.swift
//  
//
//  Created by 佐藤汰一 on 2024/08/04.
//

import Foundation

struct DiaryListFilterItem: Identifiable, Equatable {
    
    /// ID
    let id: UUID
    /// フィルター種別
    let target: DiaryListFilterTarget
    /// フィルター種別内の値
    let value: String
    
    /// フィルターの条件にヒットしたかどうか
    func isFilteringTarget(_ diaryItem: DiaryListItemFeature.State) -> Bool {
        
        switch target {
            
        case .achievement:
            guard let achievement = TrainingAchievement(value: value) else { return false }
            return diaryItem.isWin == (achievement == .achieved)
            
        case .trainingType:
            return diaryItem.trainingList.contains(value)
        }
    }
}

extension Array where Element == DiaryListFilterItem {
    
    /// フィルター種別でグルーピングしたフィルター値の辞書型に変換
    func convertToDicGroupByTarget() -> [DiaryListFilterTarget: [String]] {
        
        return Dictionary(grouping: self) { $0.target }.mapValues { $0.map { $0.value } }
    }
}
