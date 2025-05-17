//
//  TrainingTypeClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

@preconcurrency import Combine
import Foundation
import MachoCore

extension TrainingTypeClient {
        
    public static let concreteValue = TrainingTypeClient {
        
        return await fetchAll()
    } add: {
        
        return await insert($0)
    } getObserve: {
        
        return await getObserver()
    }
}

private extension TrainingTypeClient {
    
    static func fetchAll() async -> [TrainingTypeData] {
        
        return await RealmStore.shared.getRealm()?.read() ?? []
    }
    
    static func insert(_ entity: TrainingTypeData) async -> Bool {
        
        return await RealmStore.shared.getRealm()?.insert(records: [entity]) ?? false
    }
    
    static func delete(_ id: UUID) async -> Bool {
        
        return await RealmStore.shared.getRealm()?
            .delete { (entity: TrainingTypeData) in entity.id == id } ?? false
    }
    
    static func getObserver() async -> AnyPublisher<[TrainingTypeData], Never>? {
        
        return await RealmStore.shared.getRealm()?.readObjectsForObserve(type: TrainingTypeData.self)
            .eraseToAnyPublisher()
    }
}
