//
//  DiaryListFilterClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

@preconcurrency import Combine
import MachoCore

extension DiaryListFilterClient {
    
    public static let concreteValue = DiaryListFilterClient {
        
        return await fetchAll()
    } addFilter: { data in
        
        return await add(data)
    } deleteFilters: { targets in
        
        return await deleteFilters(targets)
    } getFilterListObserver: {
        
        return await getObserver()
    }
}

private extension DiaryListFilterClient {
    
    static func fetchAll() async -> [DiaryListFilterData] {
        
        logger.debug("[In]")
        return await RealmStore.shared.getRealm()?.read() ?? []
    }
    
    static func add(_ filter: DiaryListFilterData) async -> Bool {
        
        logger.debug("[In] filter: \(filter)")
        return await RealmStore.shared.getRealm()?.insert(records: [filter]) ?? false
    }
    
    static func deleteFilters(_ targets: [DiaryListFilterData]) async -> Bool {
        
        logger.debug("[In] targets: \(targets)")
        return await RealmStore.shared.getRealm()?.delete { (entity: DiaryListFilterData) in
            
            return targets.contains { $0.id == entity.id }
        }
        ?? false
    }
    
    static func getObserver() async -> AnyPublisher<[DiaryListFilterData], Never>? {
        
        logger.debug("[In]")
        guard let realm = await RealmStore.shared.getRealm() else { return nil }
        return await realm.readObjectsForObserve(type: DiaryListFilterData.self)
            .eraseToAnyPublisher()
    }
}
