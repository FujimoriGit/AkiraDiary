//
//  DiaryListFilterEntityRepositoryImpl.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

@preconcurrency import Combine
import Foundation
import MachoCore
import RealmHelper

public struct DiaryListFilterEntityRepositoryImpl: RealmUseable, Sendable {
    
    let realm: Task<RealmWrapper, any Error>
    
    public init(realm: Task<RealmWrapper, any Error>) {
        
        self.realm = realm
    }
    
    public func fetchAll() async -> [DiaryListFilterData] {
        
        logger.debug("[In]")
        return await getRealm()?.read() ?? []
    }
    
    public func add(_ filter: DiaryListFilterData) async -> Bool {
        
        logger.debug("[In] filter: \(filter)")
        return await getRealm()?.insert(records: [filter]) ?? false
    }
    
    public func deleteFilters(_ targets: [DiaryListFilterData]) async -> Bool {
        
        logger.debug("[In] targets: \(targets)")
        return await getRealm()?.delete { (entity: DiaryListFilterData) in
            
            return targets.contains { $0.id == entity.id }
        }
        ?? false
    }
    
    public func getObserver() async -> AnyPublisher<[DiaryListFilterData], Never>? {
        
        logger.debug("[In]")
        guard let realm = await getRealm() else { return nil }
        return await realm.readObjectsForObserve(type: DiaryListFilterData.self)
            .eraseToAnyPublisher()
    }
}
