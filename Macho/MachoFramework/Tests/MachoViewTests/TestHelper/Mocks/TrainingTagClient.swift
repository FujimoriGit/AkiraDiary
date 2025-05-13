//
//  TrainingTagClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/30.
//

import MachoCore
import MachoModel
import RealmHelper
import XCTest

extension TrainingTagClient {
    
    static func getMockClient(realm: RealmWrapper, initialValue: [TrainingTagData]) async -> TrainingTagClient {
        
        let repository = TrainingTagEntityRepositoryImpl(Task { realm })
        let client = TrainingTagClient {
            return await repository.fetchAll()
        } add: {
            return await repository.insert($0)
        } update: {
            return await repository.update($0)
        } getObserve: {
            return await repository.getObserver()
        }
        
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
