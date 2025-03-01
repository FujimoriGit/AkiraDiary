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
    
    public func fetchAll() async -> [ConcreteTrainingTagData] {
        
        return await ((getRealm()?.read() ?? []) as [TrainingTagEntity])
            .map { .init(id: $0.id, tagName: $0.tagName) }
    }
    
    public func insert(_ entity: ConcreteTrainingTagData) async -> Bool {
        
        let entity = TrainingTagEntity(entity)
        return await getRealm()?.insert(records: [entity]) ?? false
    }
    
    public func update(_ entity: ConcreteTrainingTagData) async -> Bool {
        
        return await getRealm()?.update(type: TrainingTypeEntity.self,
                                        value: [
                                            "id": entity.id,
                                            "name": entity.tagName
                                        ]) ?? false
    }
    
    public func delete(_ id: UUID) async -> Bool {
        
        return await getRealm()?
            .delete { (entity: TrainingTagEntity) in entity.id == id } ?? false
    }
    
    public func getObserver() async -> AnyPublisher<[ConcreteTrainingTagData], Never>? {
        
        return await getRealm()?.readObjectsForObserve(type: TrainingTagEntity.self)
            .map { $0.map { ConcreteTrainingTagData(id: $0.id, tagName: $0.tagName) } }
            .eraseToAnyPublisher()
    }
}
