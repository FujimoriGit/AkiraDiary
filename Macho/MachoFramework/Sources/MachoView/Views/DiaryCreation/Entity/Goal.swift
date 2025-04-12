//
//  MachoFramework
//
//  Goal.swift
//
//  Created by stotic-dev on 2025/03/09
//  Copyright © Macho All rights reserved.
//

import Foundation

struct Goal: Equatable, Identifiable {
    
    let id: UUID
    var trainingType: TrainingTypeData
    var numberOfSets: Int
    var setCount: Int
    
    var entity: TrainingContentData {
        
        return .init(id: id,
                     trainingType: trainingType,
                     goalNumberOfSets: numberOfSets,
                     goalSetCount: setCount,
                     actualNumberOfSets: nil,
                     actualSetCount: nil)
    }
}
