//
//  ActivityResultOfDay.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/24.
//

import Foundation

struct ActivityResultOfDay: Equatable {
    
    /// 対象日付
    let targetDate: Date
    /// 目標達成したかどうか
    let isAchieved: Bool
    /// 対象日付の日記
    let activities: [ActivityEvent]
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
