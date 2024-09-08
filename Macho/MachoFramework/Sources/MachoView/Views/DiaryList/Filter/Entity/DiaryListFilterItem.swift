//
//  DiaryListFilterItem.swift
//  
//
//  Created by 佐藤汰一 on 2024/08/04.
//

import Foundation

struct DiaryListFilterItem: Identifiable, Equatable {
    
    /// ID
    let id: String
    /// フィルター種別
    let target: DiaryListFilterTarget
    /// フィルター種別のID
    let filterItemId: UUID
    /// フィルター種別内の値
    let value: String
    
    init(target: DiaryListFilterTarget, filterItemId: UUID, value: String) {
        
        self.id = filterItemId.uuidString + String(target.num)
        self.target = target
        self.filterItemId = filterItemId
        self.value = value
    }
    
    /// 複数選択可能なフィルターかどうか
    var isMultiSelectFilter: Bool { target.isMultiSelectFilter }
    
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
