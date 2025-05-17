//
//  TrainingTagClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

@preconcurrency import Combine
import Foundation
import MachoCore

extension TrainingTagClient {
        
    public static let concreteValue = TrainingTagClient {
        
        return await fetchAll()
    } add: {
        
        return await insert($0)
    } update: {
        
        return await update($0)
    } getObserve: {
        
        return await getObserver()
    }
}

private extension TrainingTagClient {
    
    static func fetchAll() async -> [TrainingTagData] {
        
        return await RealmStore.shared.getRealm()?.read() ?? []
    }
    
    static func insert(_ entity: TrainingTagData) async -> Bool {
        
        return await RealmStore.shared.getRealm()?.insert(records: [entity]) ?? false
    }
    
    static func update(_ entity: TrainingTagData) async -> Bool {
        
        return await RealmStore.shared.getRealm()?.update(type: TrainingTagData.self,
                                        value: [
                                            "id": entity.id,
                                            "name": entity.tagName
                                        ]) ?? false
    }
    
    static func delete(_ id: UUID) async -> Bool {
        
        return await RealmStore.shared.getRealm()?
            .delete { (entity: TrainingTagData) in entity.id == id } ?? false
    }
    
    static func getObserver() async -> AnyPublisher<[TrainingTagData], Never>? {
        
        return await RealmStore.shared.getRealm()?.readObjectsForObserve(type: TrainingTagData.self)
            .eraseToAnyPublisher()
    }
}
