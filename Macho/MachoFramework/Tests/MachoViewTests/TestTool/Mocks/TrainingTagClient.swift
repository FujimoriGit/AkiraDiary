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
    
    static func getMockClient(realm: RealmWrapper) -> TrainingTagClient {
        
        let repository = TrainingTagEntityRepositoryImpl(Task { realm })
        return TrainingTagClient {
            return await repository.fetchAll()
        } add: {
            return await repository.insert($0)
        } update: {
            return await repository.update($0)
        } getObserve: {
            return await repository.getObserver()
        }
    }
}
