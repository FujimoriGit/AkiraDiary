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
    
    public func fetchAll() async -> [DiaryListFilterEntity] {
        
        logger.debug("[In]")
        return await (getRealm()?.read() ?? [])
    }
    
    public func add(_ filter: some DiaryListFilterData) async -> Bool {
        
        logger.debug("[In] filter: \(filter)")
        return await getRealm()?.insert(records: [DiaryListFilterEntity(filter)]) ?? false
    }
    
    public func deleteFilters(_ targets: [any DiaryListFilterData]) async -> Bool {
        
        logger.debug("[In] targets: \(targets)")
        return await getRealm()?.delete { (entity: DiaryListFilterEntity) in
            
            return targets.contains { $0.id == entity.id }
        }
        ?? false
    }
    
    public func getObserver() async -> AnyPublisher<[DiaryListFilterEntity], Never>? {
        
        logger.debug("[In]")
        guard let realm = await getRealm() else { return nil }
        return await realm.readObjectsForObserve(type: DiaryListFilterEntity.self)
    }
}

private extension DiaryListFilterEntityRepositoryImpl {
    
    func getUpdateDic(_ data: some DiaryListFilterData) -> [String: Any] {
        
        return [
            "id": data.id,
            "filterTarget": data.filterTarget,
            "filterId": data.filterId,
            "filterValue": data.filterValue
        ]
    }
}
