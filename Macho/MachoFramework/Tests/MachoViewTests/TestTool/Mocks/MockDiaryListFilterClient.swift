//
//  MockDiaryListFilterClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

import MachoCore
import MachoModel
import RealmHelper
import XCTest

extension DiaryListFilterClient {
    
    static func getMockClient(realm: RealmWrapper) -> DiaryListFilterClient {
        
        let repository = DiaryListFilterEntityRepositoryImpl(realm: Task { realm })
        return DiaryListFilterClient {
            
            return await repository.fetchAll()
        } addFilter: {
            
            return await repository.add($0)
        } deleteFilters: {
            
            return await repository.deleteFilters($0)
        } getFilterListObserver: {
            
            return await repository.getObserver()
        }
    }
}
