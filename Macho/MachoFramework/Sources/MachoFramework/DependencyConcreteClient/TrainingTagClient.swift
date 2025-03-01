//
//  TrainingTagClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

import Dependencies
import MachoCore
import MachoModel

extension TrainingTagClient: DependencyKey {
    
    private static let repository = TrainingTagEntityRepositoryImpl(RealmStore.shared.realm)
    
    public static let liveValue = TrainingTagClient {
        
        return await repository.fetchAll()
    } add: {
        
        return await repository.insert($0)
    } update: {
        
        return await repository.update($0)
    } getObserve: {
        
        return await repository.getObserver()
    }
}
