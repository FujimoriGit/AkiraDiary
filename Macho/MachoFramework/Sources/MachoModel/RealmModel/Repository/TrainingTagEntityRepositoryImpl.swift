//
//  TrainingTagEntityRepositoryImpl.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

import Foundation
import MachoCore
import RealmHelper

public struct TrainingTagEntityRepositoryImpl: RealmUseable, Sendable {
    
    let realm: Task<RealmWrapper, any Error>
    
    public init(_ realm: Task<RealmWrapper, any Error>) {
        
        self.realm = realm
    }
    
    public func fetchAll() async -> [TrainingTagEntity] {
        
        return await (getRealm()?.read() ?? [])
    }
    
    public func insert(_ entity: some TrainingTagData) async -> Bool {
        
        let entity = TrainingTagEntity(entity)
        return await getRealm()?.insert(records: [entity]) ?? false
    }
    
    public func delete(_ id: UUID) async -> Bool {
        
        return await getRealm()?
            .delete { (entity: TrainingTagEntity) in entity.id == id } ?? false
    }
}
