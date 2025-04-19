//
//  MachoFramework
//
//  GoalCreationUtil.swift
//
//  Created by stotic-dev on 2025/03/22
//  Copyright © Macho All rights reserved.
//

import Foundation
@testable import MachoView

extension Goal {
    
    static func create(id: UUID = UUID(),
                       trainingType: TrainingTypeData = .abs,
                       isAchieved: Bool = true) -> Self {
        
        return .init(id: id,
                     trainingType: trainingType,
                     numberOfSets: 3,
                     setCount: 3,
                     actualSetCount: isAchieved ? 3 : 1)
    }
}
