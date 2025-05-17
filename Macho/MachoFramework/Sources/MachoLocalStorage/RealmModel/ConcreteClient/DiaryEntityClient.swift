//
//  DiaryEntityClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/28.
//

@preconcurrency import Combine
import Foundation
import MachoCore

extension DiaryEntityClient {
    
    public static let concreteValue = DiaryEntityClient {
        
        return await fetchAll()
    } add: { diary in
        
        return await insertOrUpdate(diary)
    } deleteDiary: { id in
        
        return await deleteDiary(id)
    } getDiaryObserver: {
        
        return await getDiaryObserver()
    }
}

private extension DiaryEntityClient {
    
    static func fetchAll() async -> [DiaryData] {
        
        logger.debug("[In]")
        return await RealmStore.shared.getRealm()?.read() ?? []
    }
    
    static func insertOrUpdate(_ diary: DiaryData) async -> Bool {
        
        logger.debug("[In] diary: \(diary)")
        return await RealmStore.shared.getRealm()?.insert(records: [diary]) ?? false
    }
    
    static func deleteDiary(_ id: UUID) async -> Bool {
        
        logger.debug("[In] id: \(id)")
        return await RealmStore.shared.getRealm()?
            .delete { (entity: DiaryData) in entity.id == id } ?? false
    }
    
    static func getDiaryObserver() async -> AnyPublisher<[DiaryData], Never>? {
        
        logger.debug("[In]")
        guard let realm = await RealmStore.shared.getRealm() else { return nil }
        return await realm.readObjectsForObserve(type: DiaryData.self)
            .eraseToAnyPublisher()
    }
}
