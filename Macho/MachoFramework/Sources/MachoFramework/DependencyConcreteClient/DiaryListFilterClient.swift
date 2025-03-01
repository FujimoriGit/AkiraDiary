//
//  DiaryListFilterClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

import Dependencies
import MachoCore
import MachoModel

extension DiaryListFilterClient: DependencyKey {
    
    private static let repository = DiaryListFilterEntityRepositoryImpl(realm: RealmStore.shared.realm)
    
    public static let liveValue = DiaryListFilterClient {
        
        return await repository.fetchAll()
    } addFilter: { data in
        
        return await repository.add(data)
    } deleteFilters: { targets in
        
        return await repository.deleteFilters(targets)
    } getFilterListObserver: {
        
        return await repository.getObserver()
    }
}
