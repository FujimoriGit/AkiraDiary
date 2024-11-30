//
//  ConcreteTrainingContentData.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

import Foundation

public struct ConcreteTrainingContentData: TrainingContentData {
    
    public typealias TrainingType = ConcreteTrainingTypeData
    
    public let id: UUID
    public let trainingType: TrainingType?
    public let goalNumberOfSets: Int
    public let goalSetCount: Int
    public let actualNumberOfSets: Int?
    public let actualSetCount: Int?
    public let startTime: Date?
    public let endTime: Date?
    public let isAchieved: Bool
    
    public init(id: UUID,
                trainingType: TrainingType?,
                goalNumberOfSets: Int,
                goalSetCount: Int,
                actualNumberOfSets: Int?,
                actualSetCount: Int?,
                startTime: Date?,
                endTime: Date?,
                isAchieved: Bool) {
        
        self.id = id
        self.trainingType = trainingType
        self.goalNumberOfSets = goalNumberOfSets
        self.goalSetCount = goalSetCount
        self.actualNumberOfSets = actualNumberOfSets
        self.actualSetCount = actualSetCount
        self.startTime = startTime
        self.endTime = endTime
        self.isAchieved = isAchieved
    }
}
