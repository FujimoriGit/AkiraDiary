//
//  ConcreteDiaryData.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

import Foundation

public struct ConcreteDiaryData: DiaryData {
    
    public typealias GoalType = ConcreteTrainingContentData
    public typealias TagType = ConcreteTrainingTagData
    
    public let id: UUID
    public let date: Date
    public let title: String
    public let mainText: String
    public let goals: [GoalType]
    public let tags: [TagType]
    public let startTime: Date?
    public let endTime: Date?
    /// 全ての目標を達成したかどうか
    public var isAchieved: Bool {
        
        return !goals.contains { !$0.isAchieved }
    }
    
    public init(id: UUID,
                date: Date,
                title: String,
                mainText: String,
                goals: [GoalType],
                tags: [TagType],
                startTime: Date?,
                endTime: Date?) {
        
        self.id = id
        self.date = date
        self.title = title
        self.mainText = mainText
        self.goals = goals
        self.tags = tags
        self.startTime = startTime
        self.endTime = endTime
    }
}
