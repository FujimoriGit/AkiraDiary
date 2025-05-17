//
//  TrainingTagEntityRepositoryImpl.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

@preconcurrency import Combine
import Foundation
import MachoCore
import RealmHelper

public struct TrainingTagEntityRepositoryImpl: RealmUseable, Sendable {
    
    let realm: Task<RealmWrapper, any Error>
    
    public init(_ realm: Task<RealmWrapper, any Error>) {
        
        self.realm = realm
    }
    
    public func fetchAll() async -> [TrainingTagData] {
        
        return await getRealm()?.read() ?? []
    }
    
    public func insert(_ entity: TrainingTagData) async -> Bool {
        
        return await getRealm()?.insert(records: [entity]) ?? false
    }
    
    public func update(_ entity: TrainingTagData) async -> Bool {
        
        return await getRealm()?.update(type: TrainingTagData.self,
                                        value: [
                                            "id": entity.id,
                                            "name": entity.tagName
                                        ]) ?? false
    }
    
    public func delete(_ id: UUID) async -> Bool {
        
        return await getRealm()?
            .delete { (entity: TrainingTagData) in entity.id == id } ?? false
    }
    
    public func getObserver() async -> AnyPublisher<[TrainingTagData], Never>? {
        
        return await getRealm()?.readObjectsForObserve(type: TrainingTagData.self)
            .eraseToAnyPublisher()
    }
}
