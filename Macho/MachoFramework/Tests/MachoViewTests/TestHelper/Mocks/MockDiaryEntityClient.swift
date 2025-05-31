//
//  MockDiaryEntityClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

import MachoCore
import RealmHelper
import XCTest

@testable import MachoLocalStorage

extension DiaryEntityClient {
    
    static func getMockClient(realm: RealmWrapper, initialValue: [DiaryData]) async -> DiaryEntityClient {
        
        let client = DiaryEntityClient(realm: Task { realm })
        
        await registeredValue(client, initialValue)
        
        return client
    }
    
    private static func registeredValue(_ client: DiaryEntityClient, _ diaryList: [DiaryData]) async {
        
        for diary in diaryList {
            
            if !(await client.add(diary)) {
                
                fatalError("テストデータの登録失敗")
            }
        }
    }
}
