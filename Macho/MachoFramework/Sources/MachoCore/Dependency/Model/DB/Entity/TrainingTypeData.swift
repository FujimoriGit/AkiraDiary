//
//  TrainingTypeData.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

import Foundation

public struct TrainingTypeData: Equatable, Sendable {
    
    public let id: UUID
    public let name: String
    
    public init(id: UUID, name: String) {
        
        self.id = id
        self.name = name
    }
}
