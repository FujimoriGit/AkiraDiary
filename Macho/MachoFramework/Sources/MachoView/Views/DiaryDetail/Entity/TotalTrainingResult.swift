//
//  TotalTrainingResult.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/10/19.
//

import Foundation
import MachoCore

struct TotalTrainingResult: Equatable {
    
    // 時間の表示形式
    private static let displayDateFormat: Date.MachoFormat = .localeDateTime
    // 時間が表示できない場合のデフォルト文言
    private static let defaultDateDisplayText = "まだ記録されていません"
    
    /// トレーニング種目数
    let trainingCount: Int
    ///　トレーニングが終了しているかどうか
    let isFinished: Bool
    /// 全ての目標を達成したかどうか
    let isAchievedTotalGoal: Bool
    
    /// トレーニング開始時間
    let startDateDisplayText: String
    
    /// トレーニング終了時間
    let endDateDisplayText: String
    
    /// トレーニング総時間
    let totalTrainingTimeDurationText: String
    
    init(_ diary: Diary) {
        
        trainingCount = diary.goals.count
        startDateDisplayText = Self.getDisplayDateText(diary.createdAt)
        
        if case .finished(let info) = diary.status {
            
            isFinished = true
            isAchievedTotalGoal = info.isAchieved
            endDateDisplayText = Self.getDisplayDateText(info.endTime)
            totalTrainingTimeDurationText = Self.getTotalTrainingTimeDurationText(
                from: diary.createdAt,
                to: info.endTime
            )
        }
        else {
            
            isFinished = false
            isAchievedTotalGoal = false
            endDateDisplayText = Self.getDisplayDateText(nil)
            totalTrainingTimeDurationText = Self.getTotalTrainingTimeDurationText(
                from: diary.createdAt,
                to: nil
            )
        }
    }
}

private extension TotalTrainingResult {
    
    static func getDisplayDateText(_ date: Date?) -> String {
        
        guard let text = date?.formatted(Self.displayDateFormat,
                                         timeZone: .autoupdatingCurrent) else {
            
            return Self.defaultDateDisplayText
        }
        
        return text
    }
    
    static func getTotalTrainingTimeDurationText(from startDate: Date, to endDate: Date?) -> String {
        
        guard let endDate else { return Self.defaultDateDisplayText }
        return getDisplayDateText(Date(timeIntervalSince1970: endDate.timeIntervalSince(startDate)))
    }
}
