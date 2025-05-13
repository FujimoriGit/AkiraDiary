//
//  MockDiaryEntityClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

import MachoCore
import MachoModel
import RealmHelper
import XCTest

extension DiaryEntityClient {
    
    static func getMockClient(realm: RealmWrapper, initialValue: [DiaryData]) async -> DiaryEntityClient {
        
        let repository = DiaryEntityRepositoryImpl(Task { realm })
        let client = DiaryEntityClient {
            
            return await repository.fetchAll()
        } add: {
            
            return await repository.insertOrUpdate($0)
        } deleteDiary: {
            
            return await repository.deleteDiary($0)
        } getDiaryObserver: {
            
            return await repository.getDiaryObserver()
        }
        
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
