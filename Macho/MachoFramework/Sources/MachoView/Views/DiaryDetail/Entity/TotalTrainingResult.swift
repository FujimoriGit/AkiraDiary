//
//  TotalTrainingResult.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/10/19.
//

import Foundation

struct TotalTrainingResult {
    
    // 時間の表示形式
    private static let displayDateFormat = Date.Format(time: .shortJp)
    // 時間が表示できない場合のデフォルト文言
    private static let defaultDateDisplayText = "まだ記録されていません"
    
    /// トレーニング種目数
    let trainingCount: Int
    /// 全ての目標を達成したかどうか
    let isAchievedTotalGoal: Bool
    private let startDate: Date?
    private let endDate: Date?
    
    /// トレーニング開始時間
    var startDateDisplayText: String {
        
        return getDisplayDateText(startDate)
    }
    
    /// トレーニング終了時間
    var endDateDisplayText: String {
        
        return getDisplayDateText(endDate)
    }
    
    /// トレーニング総時間
    var totalTrainingTimeDurationText: String {
        
        guard let startDate, let endDate else { return Self.defaultDateDisplayText }
        return getDisplayDateText(Date(timeIntervalSince1970: endDate.timeIntervalSince(startDate)))
    }
    
    init(_ diary: DiaryData) {
        
        trainingCount = diary.goals.count
        isAchievedTotalGoal = diary.isAchieved
        startDate = diary.goals.compactMap(\.startTime).min { $0 < $1 }
        endDate = diary.goals.compactMap(\.endTime).max { $0 < $1 }
    }
}

private extension TotalTrainingResult {
    
    func getDisplayDateText(_ date: Date?) -> String {
        
        guard let text = date?.toString(Self.displayDateFormat,
                                        timeZone: .autoupdatingCurrent) else {
            
            return Self.defaultDateDisplayText
        }
        
        return text
    }
}
