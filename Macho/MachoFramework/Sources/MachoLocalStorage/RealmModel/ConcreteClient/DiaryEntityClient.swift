//
//  DiaryEntityClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/28.
//

@preconcurrency import Combine
import Foundation
import MachoCore
import RealmHelper

extension DiaryEntityClient {
    
    init(realm: Task<RealmWrapper, Never>) {
        
        self = DiaryEntityClient {
            
            return await Self.fetchAll(realm: realm)
        } add: { diary in
            
            return await Self.insertOrUpdate(realm: realm, diary: diary)
        } deleteDiary: { id in
            
            return await Self.deleteDiary(realm: realm, id: id)
        } getDiaryObserver: {
            
            return await Self.getDiaryObserver(realm: realm)
        }
    }
    
    public static let concreteValue = DiaryEntityClient(realm: RealmStore.shared.getRealm())
}

private extension DiaryEntityClient {
    
    static func fetchAll(realm: Task<RealmWrapper, Never>) async -> [DiaryData] {
        
        return await realm.value.read()
    }
    
    static func insertOrUpdate(realm: Task<RealmWrapper, Never>, diary: DiaryData) async -> Bool {
        
        return await realm.value.insert(records: [diary])
    }
    
    static func deleteDiary(realm: Task<RealmWrapper, Never>, id: UUID) async -> Bool {
        
        return await realm.value
            .delete { (entity: DiaryData) in entity.id == id }
    }
    
    static func getDiaryObserver(realm: Task<RealmWrapper, Never>) async -> AnyPublisher<[DiaryData], Never>? {
        
        return await realm.value.readObjectsForObserve(type: DiaryData.self)
            .eraseToAnyPublisher()
    }
}
