//
//  MockTrainingTypeClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

import MachoCore
import MachoModel
import RealmHelper
import XCTest

extension TrainingTypeClient {
    
    static func getMockClient(realm: RealmWrapper, initialValue: [TrainingTypeData]) async -> TrainingTypeClient {
        
        let repository = TrainingTypeEntityRepositoryImpl(Task { realm })
        let client = TrainingTypeClient {
            
            return await repository.fetchAll()
        } add: {
            
            return await repository.insert($0)
        } getObserve: {
            
            return await repository.getObserver()
        }
        
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
