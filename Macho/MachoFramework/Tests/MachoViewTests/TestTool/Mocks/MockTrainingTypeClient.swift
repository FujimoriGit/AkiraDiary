//
//  MockTrainingTypeClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

import MachoCore
import XCTest

extension TrainingTypeClient {
    
    static func getMockClient(expectedFetchList: [ConcreteTrainingTypeData] = []) -> TrainingTypeClient {
        
        return TrainingTypeClient(fetchAllType: { expectedFetchList })
    }
}
