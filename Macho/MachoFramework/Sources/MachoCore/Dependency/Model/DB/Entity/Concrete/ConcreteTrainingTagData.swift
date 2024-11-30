//
//  ConcreteTrainingTagData.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

import Foundation

public struct ConcreteTrainingTagData: TrainingTagData {
    
    public let id: UUID
    public let tagName: String
    
    public init(id: UUID, tagName: String) {
        
        self.id = id
        self.tagName = tagName
    }
}
