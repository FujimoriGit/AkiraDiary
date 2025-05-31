//
//  MockDiaryListFilterClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

import MachoCore
import RealmHelper
import XCTest

@testable import MachoLocalStorage

extension DiaryListFilterClient {
    
    static func getMockClient(realm: RealmWrapper, initialValue: [DiaryListFilterData]) async -> DiaryListFilterClient {
        
        let client = DiaryListFilterClient(realm: Task { realm })
        
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
