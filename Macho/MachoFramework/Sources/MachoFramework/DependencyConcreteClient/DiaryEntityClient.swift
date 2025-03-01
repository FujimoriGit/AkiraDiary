//
//  DiaryEntityClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/28.
//

import Dependencies
import MachoCore
import MachoModel

extension DiaryEntityClient: DependencyKey {
    
    private static let repository = DiaryEntityRepositoryImpl(RealmStore.shared.realm)
    
    public static let liveValue = DiaryEntityClient {
        
        return await repository.fetchAll()
    } add: {
        
        return await repository.insertOrUpdate($0)
    } deleteDiary: {
        
        return await repository.deleteDiary($0)
    } getDiaryObserver: {
        
        return await repository.getDiaryObserver()
    }
}
