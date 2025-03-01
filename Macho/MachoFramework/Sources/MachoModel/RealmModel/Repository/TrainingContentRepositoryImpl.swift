//
//  MachoFramework
//
//  TrainingContentRepositoryImpl.swift
//
//  Created by stotic-dev on 2025/02/24
//  Copyright © Macho All rights reserved.
//

@preconcurrency import Combine
import Foundation
import MachoCore
import RealmHelper

public struct TrainingContentRepositoryImpl: Sendable, RealmUseable {
    
    let realm: Task<RealmWrapper, any Error>
    
    public init(_ realm: Task<RealmWrapper, any Error>) {
        
        self.realm = realm
    }
    
    public func fetchAll() async -> [ConcreteTrainingContentData] {
        
        return await ((getRealm()?.read() ?? []) as [TrainingContentEntity])
            .map { .init(entity: $0) }
    }
    
    public func insert(_ entity: ConcreteTrainingContentData) async -> Bool {
        
        let entity = TrainingContentEntity(entity)
        return await getRealm()?.insert(records: [entity]) ?? false
    }
    
    public func delete(_ id: UUID) async -> Bool {
        
        return await getRealm()?
            .delete { (entity: TrainingContentEntity) in entity.id == id } ?? false
    }
    
    public func getObserver() async -> AnyPublisher<[ConcreteTrainingContentData], Never>? {
        
        logger.debug("[In]")
        guard let realm = await getRealm() else { return nil }
        return await realm.readObjectsForObserve(type: TrainingContentEntity.self)
            .map { $0.map { .init(entity: $0) } }
            .eraseToAnyPublisher()
    }
}
