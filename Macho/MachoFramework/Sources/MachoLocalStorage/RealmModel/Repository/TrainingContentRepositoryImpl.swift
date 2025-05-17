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
    
    public func fetchAll() async -> [TrainingContentData] {
        
        return await getRealm()?.read() ?? []
    }
    
    public func insert(_ entity: TrainingContentData) async -> Bool {
        
        return await getRealm()?.insert(records: [entity]) ?? false
    }
    
    public func delete(_ id: UUID) async -> Bool {
        
        return await getRealm()?
            .delete { (entity: TrainingContentData) in entity.id == id } ?? false
    }
    
    public func getObserver() async -> AnyPublisher<[TrainingContentData], Never>? {
        
        logger.debug("[In]")
        guard let realm = await getRealm() else { return nil }
        return await realm.readObjectsForObserve(type: TrainingContentData.self)
            .eraseToAnyPublisher()
    }
}
