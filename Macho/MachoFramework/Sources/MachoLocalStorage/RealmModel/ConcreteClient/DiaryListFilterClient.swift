//
//  DiaryListFilterClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

@preconcurrency import Combine
import MachoCore
import RealmHelper

extension DiaryListFilterClient {
    
    init(realm: Task<RealmWrapper, Never>) {
        
        self = DiaryListFilterClient {
            
            return await Self.fetchAll(realm: realm)
        } addFilter: { data in
            
            return await Self.add(realm: realm, filter: data)
        } deleteFilters: { targets in
            
            return await Self.deleteFilters(realm: realm, targets: targets)
        } getFilterListObserver: {
            
            return await Self.getObserver(realm: realm)
        }
    }
    
    public static let concreteValue = DiaryListFilterClient(realm: RealmStore.shared.getRealm())
}

private extension DiaryListFilterClient {
    
    static func fetchAll(realm: Task<RealmWrapper, Never>) async -> [DiaryListFilterData] {
        
        return await realm.value.read()
    }
    
    static func add(realm: Task<RealmWrapper, Never>, filter: DiaryListFilterData) async -> Bool {
        
        return await realm.value.insert(records: [filter])
    }
    
    static func deleteFilters(realm: Task<RealmWrapper, Never>, targets: [DiaryListFilterData]) async -> Bool {
        
        return await realm.value.delete { (entity: DiaryListFilterData) in
            
            return targets.contains { $0.id == entity.id }
        }
    }
    
    static func getObserver(realm: Task<RealmWrapper, Never>) async -> AnyPublisher<[DiaryListFilterData], Never>? {
        
        return await realm.value.readObjectsForObserve(type: DiaryListFilterData.self)
            .eraseToAnyPublisher()
    }
}
