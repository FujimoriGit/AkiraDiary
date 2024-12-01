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
    } deleteDiary: { id in
        
        return await repository.deleteDiary(id)
    } getDiaryObserver: {
        
        guard let publisher = await repository.getDiaryObserver() else { return nil }
        return publisher
            .map { $0 as [any DiaryData] }
            .eraseToAnyPublisher()
    }
}
