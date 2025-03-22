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
    var trainingType: TrainingType
    var numberOfSets: Int
    var setCount: Int
    var actualSetCount: Int
    
    var isAchieved: Bool {
        
        return setCount <= actualSetCount
    }
    
    init(id: UUID,
         trainingType: TrainingType,
         numberOfSets: Int,
         setCount: Int,
         actualSetCount: Int = 0) {
        
        self.id = id
        self.trainingType = trainingType
        self.numberOfSets = numberOfSets
        self.setCount = setCount
        self.actualSetCount = actualSetCount
    }
    
    func incrementSet() -> Self {
        
        return .init(id: id,
                     trainingType: trainingType,
                     numberOfSets: numberOfSets,
                     setCount: setCount,
                     actualSetCount: actualSetCount + 1)
    }
    
    func decrementSet() -> Self {
        
        return .init(id: id,
                     trainingType: trainingType,
                     numberOfSets: numberOfSets,
                     setCount: setCount,
                     actualSetCount: actualSetCount == .zero ? .zero : actualSetCount - 1)
    }
}
