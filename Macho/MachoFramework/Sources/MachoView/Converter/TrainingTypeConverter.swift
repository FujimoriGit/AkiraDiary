//
//  MachoFramework
//
//  TrainingTypeConverter.swift
//
//  Created by stotic-dev on 2025/03/22
//  Copyright © Macho All rights reserved.
//

import MachoCore

enum TrainingTypeConverter {
    
    static func toType(_ entity: TrainingTypeData) -> TrainingType {
        
        return .init(id: entity.id, name: entity.name)
    }
    
    static func toEntity(_ trainingType: TrainingType) -> TrainingTypeData {
        
        return .init(id: trainingType.id, name: trainingType.name)
    }
}
