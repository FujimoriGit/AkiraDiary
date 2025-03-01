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
    
    static func getMockClient(realm: RealmWrapper) -> DiaryEntityClient {
        
        let repository = DiaryEntityRepositoryImpl(Task { realm })
        return DiaryEntityClient {
            
            return await repository.fetchAll()
        } add: {
            
            return await repository.insertOrUpdate($0)
        } deleteDiary: {
            
            return await repository.deleteDiary($0)
        } getDiaryObserver: {
            
            return await repository.getDiaryObserver()
        }
    }
}
