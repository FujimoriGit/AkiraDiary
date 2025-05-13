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
    
    static func getMockClient(realm: RealmWrapper, initialValue: [DiaryListFilterData]) async -> DiaryListFilterClient {
        
        let repository = DiaryListFilterEntityRepositoryImpl(realm: Task { realm })
        let client = DiaryListFilterClient {
            
            return await repository.fetchAll()
        } addFilter: {
            
            return await repository.add($0)
        } deleteFilters: {
            
            return await repository.deleteFilters($0)
        } getFilterListObserver: {
            
            return await repository.getObserver()
        }
        
        await registeredValue(client, initialValue)
        
        return client
    }
    
    private static func registeredValue(_ client: DiaryListFilterClient, _ filters: [DiaryListFilterData]) async {
        
        for filter in filters {
            
            if !(await client.addFilter(filter)) {
                
                fatalError("テストデータの登録失敗")
            }
        }
    }
}
