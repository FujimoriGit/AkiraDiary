//
//  MockTrainingTypeClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

import MachoCore
import RealmHelper
import XCTest

@testable import MachoLocalStorage

extension TrainingTypeClient {
    
    static func getMockClient(realm: RealmWrapper, initialValue: [TrainingTypeData]) async -> TrainingTypeClient {
        
        let client = TrainingTypeClient(realm: Task { realm })
        
        await registeredValue(client, initialValue)
        
        return client
    }
    
    private static func registeredValue(_ client: TrainingTypeClient, _ trainingTypeList: [TrainingTypeData]) async {
        
        for trainingType in trainingTypeList {
            
            if !(await client.add(trainingType)) {
                
                fatalError("テストデータの登録失敗")
            }
        }
    }
}
