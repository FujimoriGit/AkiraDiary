//
//  DiaryEntityRepositoryImpl.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/28.
//

import Combine
import Foundation
import MachoCore
import RealmHelper

public struct DiaryEntityRepositoryImpl: RealmUseable {
        
    let realm: Task<RealmAccessible, Error>
    
    public init(_ realm: Task<RealmAccessible, Error>) {
        
        self.realm = realm
    }
    
    public func fetchAll() async -> [DiaryEntity] {
        
        return await (getRealm()?.read(where: nil) ?? [])
    }
    
    public func insertOrUpdate(_ diary: some DiaryData) async -> Bool {
        
        return await getRealm()?.insert(records: [DiaryEntity(diary)]) ?? false
    }
    
    public func deleteDiary(_ id: UUID) async -> Bool {
        
        return await getRealm()?
            .delete { (entity: DiaryEntity) in entity.id == id } ?? false
    }
    
    public func getDiaryObserver() async -> AnyPublisher<[DiaryEntity], Never>? {
        
        guard let realm = await getRealm() else { return nil }
        return await realm.getEntityChangeObserver()
    }
}
