//
//  TrainingTypeEntityRepositoryImpl.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

import Foundation
import MachoCore
import RealmHelper

public struct TrainingTypeEntityRepositoryImpl: RealmUseable, Sendable {
    
    let realm: Task<RealmWrapper, any Error>
    
    public init(_ realm: Task<RealmWrapper, any Error>) {
        
        self.realm = realm
    }
    
    public func fetchAll() async -> [TrainingTypeEntity] {
        
        return await (getRealm()?.read() ?? [])
    }
    
    public func insert(_ entity: some TrainingTypeData) async -> Bool {
        
        let entity = TrainingTypeEntity(entity)
        return await getRealm()?.insert(records: [entity]) ?? false
    }
    
    public func delete(_ id: UUID) async -> Bool {
        
        return await getRealm()?
            .delete { (entity: TrainingTypeEntity) in entity.id == id } ?? false
    }
}
