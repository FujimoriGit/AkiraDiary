//
//  ConcreteTrainingTypeData.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

import Foundation

public struct ConcreteTrainingTypeData: TrainingTypeData {
    
    public let id: UUID
    public let name: String
    
    public init(id: UUID, name: String) {
        
        self.id = id
        self.name = name
    }
}
