//
//  TrainingTagClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

@preconcurrency import Combine
import Foundation
import MachoCore
import RealmHelper

extension TrainingTagClient {
    
    init(realm: Task<RealmWrapper, Never>) {
        
        self = TrainingTagClient {
            
            return await Self.fetchAll(realm: realm)
        } add: {
            
            return await Self.insert(realm: realm, entity: $0)
        } update: {
            
            return await Self.update(realm: realm, entity: $0)
        } getObserve: {
            
            return await Self.getObserver(realm: realm)
        }
    }
        
    public static let concreteValue = TrainingTagClient(realm: RealmStore.shared.getRealm())
}

private extension TrainingTagClient {
    
    static func fetchAll(realm: Task<RealmWrapper, Never>) async -> [TrainingTagData] {
        
        return await realm.value.read()
    }
    
    static func insert(realm: Task<RealmWrapper, Never>, entity: TrainingTagData) async -> Bool {
        
        return await realm.value.insert(records: [entity])
    }
    
    static func update(realm: Task<RealmWrapper, Never>, entity: TrainingTagData) async -> Bool {
        
        return await realm.value.update(
            type: TrainingTagData.self,
            value: [
                "id": entity.id,
                "name": entity.tagName
            ]
        )
    }
    
    static func delete(realm: Task<RealmWrapper, Never>, id: UUID) async -> Bool {
        
        return await realm.value
            .delete { (entity: TrainingTagData) in entity.id == id }
    }
    
    static func getObserver(realm: Task<RealmWrapper, Never>) async -> AnyPublisher<[TrainingTagData], Never>? {
        
        return await realm.value.readObjectsForObserve(type: TrainingTagData.self)
            .eraseToAnyPublisher()
    }
}
