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
    
    public func fetchAll() async -> [ConcreteDiaryListFilterData] {
        
        logger.debug("[In]")
        return await ((getRealm()?.read() ?? []) as [DiaryListFilterEntity])
            .map { .init(entity: $0) }
    }
    
    public func add(_ filter: ConcreteDiaryListFilterData) async -> Bool {
        
        logger.debug("[In] filter: \(filter)")
        return await getRealm()?.insert(records: [DiaryListFilterEntity(filter)]) ?? false
    }
    
    public func deleteFilters(_ targets: [ConcreteDiaryListFilterData]) async -> Bool {
        
        logger.debug("[In] targets: \(targets)")
        return await getRealm()?.delete { (entity: DiaryListFilterEntity) in
            
            return targets.contains { $0.id == entity.id }
        }
        ?? false
    }
    
    public func getObserver() async -> AnyPublisher<[ConcreteDiaryListFilterData], Never>? {
        
        logger.debug("[In]")
        guard let realm = await getRealm() else { return nil }
        return await realm.readObjectsForObserve(type: DiaryListFilterEntity.self)
            .map { $0.map {
                
                ConcreteDiaryListFilterData(id: $0.id,
                                            filterTarget: $0.filterTarget,
                                            filterId: $0.filterId,
                                            filterValue: $0.filterValue)
            }}
            .eraseToAnyPublisher()
    }
}
