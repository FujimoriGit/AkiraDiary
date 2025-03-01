//
//  TrainingTypeClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

import Dependencies
import MachoCore
import MachoModel

extension TrainingTypeClient: DependencyKey {
    
    private static let repository = TrainingTypeEntityRepositoryImpl(RealmStore.shared.realm)
    
    public static let liveValue = TrainingTypeClient {
        
        return await repository.fetchAll()
    } add: {
        
        return await repository.insert($0)
    } getObserve: {
        
        return await repository.getObserver()
    }

}
