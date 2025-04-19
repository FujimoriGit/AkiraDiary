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
    func isMatchFilter(diaryStatus: DiaryStatus, trainingList: [UUID], tagList: [UUID]) -> Bool {
        
        switch target {
            
        case .achievement:
            return isMatchAchievement(diaryStatus: diaryStatus)
            
        case .trainingType:
            return trainingList.contains(filterItemId)
            
        case .tag:
            return tagList.contains(filterItemId)
        }
    }
}

private extension DiaryListFilterItem {
    
    func isMatchAchievement(diaryStatus: DiaryStatus) -> Bool {
        
        guard let achievement = TrainingAchievement(value: value) else { return false }
        switch diaryStatus {
            
        case .training:
            return achievement == .training
            
        case .finished(let isAchieved):
            guard achievement != .training else { return false }
            return isAchieved == (achievement == .achieved)
        }
    }
}
