//
//  TotalTrainingResult.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/10/19.
//

import Foundation
import MachoCore

struct TotalTrainingResult: Equatable {
    
    // 時間が表示できない場合のデフォルト文言
    private static let defaultDateDisplayText = "まだ記録されていません"
    
    /// トレーニング種目数
    let trainingCount: Int
    
    /// トレーニング開始日
    let startDateDisplayText: String
    
    /// トレーニング総時間
    let totalTrainingTimeDurationText: String
    
    init(_ diary: Diary) {
        
        trainingCount = diary.goals.count
        startDateDisplayText = Self.getDisplayDateText(date: diary.createdAt)
        
        if case .finished(let info) = diary.status {
            
            totalTrainingTimeDurationText = Self.getTotalTrainingTimeDurationText(
                from: diary.createdAt,
                to: info.endTime
            )
        }
        else {
            
            totalTrainingTimeDurationText = Self.defaultDateDisplayText
        }
    }
}

private extension TotalTrainingResult {
    
    static func getDisplayDateText(date: Date) -> String {
        
        return date.formatted(.localDate)
    }
    
    static func getTotalTrainingTimeDurationText(from startDate: Date,
                                                 to endDate: Date?) -> String {
        
        guard let endDate else { return Self.defaultDateDisplayText }
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: startDate, to: endDate) ?? Self.defaultDateDisplayText
    }
}
