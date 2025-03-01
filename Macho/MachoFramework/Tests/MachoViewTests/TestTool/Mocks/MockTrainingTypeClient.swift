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
    
    static func getMockClient(realm: RealmWrapper) -> TrainingTypeClient {
        
        let repository = TrainingTypeEntityRepositoryImpl(Task { realm })
        return TrainingTypeClient {
            
            return await repository.fetchAll()
        } add: {
            
            return await repository.insert($0)
        } getObserve: {
            
            return await repository.getObserver()
        }
    }
}
