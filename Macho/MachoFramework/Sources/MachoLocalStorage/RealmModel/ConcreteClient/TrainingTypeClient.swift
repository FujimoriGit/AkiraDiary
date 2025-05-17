//
//  TrainingTypeClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

@preconcurrency import Combine
import Foundation
import MachoCore
import RealmHelper

public extension TrainingTypeClient {
    
    init(realm: Task<RealmWrapper, Never>) {
        
        self = TrainingTypeClient {
            
            return await Self.fetchAll(realm: realm)
        } add: {
            
            return await Self.insert(realm: realm, entity: $0)
        } getObserve: {
            
            return await Self.getObserver(realm: realm)
        }
    }
        
    static let concreteValue = TrainingTypeClient(realm: RealmStore.shared.getRealm())
}

private extension TrainingTypeClient {
    
    static func fetchAll(realm: Task<RealmWrapper, Never>) async -> [TrainingTypeData] {
        
        return await realm.value.read()
    }
    
    static func insert(realm: Task<RealmWrapper, Never>, entity: TrainingTypeData) async -> Bool {
        
        return await realm.value.insert(records: [entity])
    }
    
    static func delete(realm: Task<RealmWrapper, Never>, id: UUID) async -> Bool {
        
        return await realm.value
            .delete { (entity: TrainingTypeData) in entity.id == id }
    }
    
    static func getObserver(realm: Task<RealmWrapper, Never>) async -> AnyPublisher<[TrainingTypeData], Never>? {
        
        return await realm.value.readObjectsForObserve(type: TrainingTypeData.self)
            .eraseToAnyPublisher()
    }
}
