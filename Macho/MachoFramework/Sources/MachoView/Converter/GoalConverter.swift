//
//  MachoFramework
//
//  GoalConverter.swift
//
//  Created by stotic-dev on 2025/03/20
//  Copyright © Macho All rights reserved.
//

import MachoCore

enum GoalConverter {
    
    static func toGoal(_ entity: TrainingContentData) -> Goal? {
        
        guard let trainingType = entity.trainingType else { return nil }
        return .init(id: entity.id,
                     trainingType: TrainingTypeConverter.toType(trainingType),
                     numberOfSets: entity.goalNumberOfSets,
                     setCount: entity.goalSetCount,
                     actualSetCount: entity.actualSetCount ?? 0)
    }
    
    static func toEntity(_ goal: Goal) -> TrainingContentData {
        
        return .init(id: goal.id,
                     trainingType: TrainingTypeConverter.toEntity(goal.trainingType),
                     goalNumberOfSets: goal.numberOfSets,
                     goalSetCount: goal.setCount,
                     actualNumberOfSets: nil,
                     actualSetCount: goal.actualSetCount,
                     isAchieved: goal.isAchieved)
    }
}
