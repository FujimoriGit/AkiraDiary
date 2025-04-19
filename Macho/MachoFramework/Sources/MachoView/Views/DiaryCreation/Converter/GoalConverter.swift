//
//  MachoFramework
//
//  GoalConverter.swift
//
//  Created by stotic-dev on 2025/03/20
//  Copyright © Macho All rights reserved.
//

enum GoalConverter {
    
    static func toGoal(_ entity: TrainingContentData) -> Goal? {
        
        guard let trainingType = entity.trainingType else { return nil }
        return .init(id: entity.id,
                     trainingType: trainingType,
                     numberOfSets: entity.goalNumberOfSets,
                     setCount: entity.goalSetCount,
                     actualSetCount: entity.actualSetCount ?? 0)
    }
}
