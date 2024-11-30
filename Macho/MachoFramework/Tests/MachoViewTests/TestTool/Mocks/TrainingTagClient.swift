//
//  TrainingTagClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/30.
//


import MachoCore
import XCTest

extension TrainingTagClient {
    
    static func getMockClient(expectedFetchList: [ConcreteTrainingTagData] = []) -> TrainingTagClient {
        
        return TrainingTagClient(fetchAll: { expectedFetchList })
    }
}
