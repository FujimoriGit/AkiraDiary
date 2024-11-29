//
//  DiaryListFilterEntityRepositoryImpl.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

import Combine
import Foundation
import MachoCore
import RealmHelper

public struct DiaryListFilterEntityRepositoryImpl: RealmUseable {
    
    let realm: Task<RealmAccessible, any Error>
    
    public init(realm: Task<RealmAccessible, any Error>) {
        
        self.realm = realm
    }
    
    public func fetchAll() async -> [DiaryListFilterEntity] {
        
        return await (getRealm()?.read(where: nil) ?? [])
    }
    
    public func add(_ filter: some DiaryListFilterData) async -> Bool {
        
        return await getRealm()?.insert(records: [DiaryListFilterEntity(filter)]) ?? false
    }
    
    public func updateFilter(_ filter: some DiaryListFilterData) async -> Bool {
        
        return await getRealm()?
            .update(type: DiaryListFilterEntity.self, value: getUpdateDic(filter)) ?? false
    }
    
    public func deleteFilters(_ targets: [any DiaryListFilterData]) async -> Bool {
        
        return await getRealm()?.delete { (entity: DiaryListFilterEntity) in
            
            return targets.contains { $0.id == entity.id }
        }
        ?? false
    }
    
    public func getObserver() -> AnyPublisher<[DiaryListFilterEntity], Never> {
        
        let executor = DiaryListFilterEntity.executor
        executor.startObservation()
        return executor.getPublisher()
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
