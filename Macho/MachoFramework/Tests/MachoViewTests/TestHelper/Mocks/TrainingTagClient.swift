//
//  TrainingTagClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/30.
//

import MachoCore
import RealmHelper
import XCTest

@testable import MachoLocalStorage

extension TrainingTagClient {
    
    static func getMockClient(realm: RealmWrapper, initialValue: [TrainingTagData]) async -> TrainingTagClient {
        
        let client = TrainingTagClient(realm: Task { realm })
        
        await registeredValue(client, initialValue)
        
        return client
    }
    
    private static func registeredValue(_ client: TrainingTagClient, _ value: [TrainingTagData]) async {
        
        for data in value {
            
            if !(await client.add(data)) {
                
                fatalError("テストデータの登録失敗")
            }
        }
    }
}
