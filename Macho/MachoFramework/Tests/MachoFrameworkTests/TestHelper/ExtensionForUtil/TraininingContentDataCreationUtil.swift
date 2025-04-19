//
//  MachoFramework
//
//  TraininingContentsDataCreationUtil.swift
//
//  Created by stotic-dev on 2025/01/24
//  Copyright © Macho All rights reserved.
//

import Foundation
@testable import MachoView

extension TrainingContentData {
    
    static func create(id: UUID = UUID(),
                       trainingType: TrainingTypeData = .abs,
                       isAchieved: Bool = true) -> Self {
        
        return .init(id: id,
                     trainingType: trainingType,
                     goalNumberOfSets: 3,
                     goalSetCount: 3,
                     actualNumberOfSets: isAchieved ? 3 : 1,
                     actualSetCount: 3)
    }
    
    init(_ goal: Goal) {
        
        self.init(id: goal.id,
                  trainingType: goal.trainingType,
                  goalNumberOfSets: goal.numberOfSets,
                  goalSetCount: goal.setCount,
                  actualNumberOfSets: nil,
                  actualSetCount: goal.actualSetCount)
    }
}
