//
//  ActivityResultOfDay.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/24.
//

import Foundation

struct ActivityResultOfDay: Equatable {
    
    /// 対象日付
    let targetDate: DateComponents
    /// 対象日付の日記
    let activities: [ActivityEvent]
    /// 目標達成したかどうか
    var isAchieved: Bool {
        
        // 全ての日記が目標達成している場合は、その日付の目標達成とみなす
        return !activities.contains { !$0.isAchieved }
    }
    
    var calendarDecoration: ActivityResultDecoration { ActivityResultDecoration(activityResult: self) }
}

extension ActivityResultOfDay {
    
    init(dayOfdiaries: [DiaryData]) {
        
        if dayOfdiaries.isEmpty {
            
            // 空の配列が入力されることを想定していない
            assertionFailure("Empty diaries.")
        }
        
        targetDate = Calendar.current.dateComponents([.year, .month, .day],
                                                     from: dayOfdiaries[0].date)
        activities = dayOfdiaries.map {
            
            .init(id: $0.id,
                  title: $0.title,
                  isAchieved: $0.isAchieved)
        }
    }
}

// MARK: - struct definition

extension ActivityResultOfDay {
    
    struct ActivityEvent: Equatable {
        
        /// 日記ID
        let id: UUID
        /// 日記のタイトル
        let title: String
        /// 日記単位で目標達成したかどうか
        let isAchieved: Bool
    }
}
