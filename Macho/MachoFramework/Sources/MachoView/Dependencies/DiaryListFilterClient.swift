//
//  DiaryListFilterClient.swift
//
//
//  Created by 佐藤汰一 on 2024/08/10.
//

import Combine
import ComposableArchitecture
import RealmHelper

struct DiaryListFilterClient {
    
    /// 日記リストのフィルター追加
    /// - Parameters:
    ///  - filter: 追加するフィルター
    /// - Returns: trueであれば削除成功、そうでなければ失敗
    var addFilter: (_ filter: DiaryListFilterItem) async -> Bool
    
    /// 日記リストのフィルター更新
    /// - Parameters:
    ///  - filter: 更新後のフィルター
    /// - Returns: trueであれば削除成功、そうでなければ失敗
    var updateFilter: (_ filter: DiaryListFilterItem) async -> Bool
    
    /// 日記リストのフィルター削除
    /// - Parameters:
    ///  - targets: 削除対象のフィルター項目
    /// - Returns: trueであれば削除成功、そうでなければ失敗
    var deleteFilters: (_ targets: [DiaryListFilterItem]) async -> Bool
    
    /// 現在設定されている日記リストのフィルターを返す
    var fetchFilterList: () async -> [DiaryListFilterItem]
    
    /// 日記リストのフィルター設定が更新を監視用のPublisherを返す
    var getFilterListObserver: () -> AnyPublisher<[DiaryListFilterItem], Never>
}

extension DiaryListFilterClient: DependencyKey {
    
    static var liveValue: DiaryListFilterClient = DiaryListFilterClient {
        
        return await RealmAccessor().insert(records: [DiaryListFilterEntity(id: $0.id,
                                                                            filterTarget: $0.target.rawValue,
                                                                            filterValue: $0.value)])
    } updateFilter: { filter in
        
        // filterValueを更新する辞書を生成
        let updateValue = ["id": filter.id, "filterValue": filter.value]
        return await RealmAccessor().update(type: DiaryListFilterEntity.self, value: updateValue)
    } deleteFilters: { targets in
        
        return await RealmAccessor().delete(type: DiaryListFilterEntity.self) { entity in
            
            return targets.contains(where: { $0.target.rawValue == entity.filterTarget && $0.value == entity.filterValue })
        }
        
    } fetchFilterList: {
        
        return convertFilterEntityToItem(await RealmAccessor().read(type: DiaryListFilterEntity.self))
    } getFilterListObserver: {
        
        let executor =  DiaryListFilterEntity.executor
        executor.startObservation()
        return executor.getPublisher().map { convertFilterEntityToItem($0) }.eraseToAnyPublisher()
    }
}

private extension DiaryListFilterClient {
    
    static func convertFilterEntityToItem(_ entities: [DiaryListFilterEntity]) -> [DiaryListFilterItem] {
        
        return entities.compactMap {
            
            guard let target = DiaryListFilterTarget(rawValue: $0.filterTarget) else { return nil }
            return DiaryListFilterItem(id: $0.id, target: target, value: $0.filterValue)
        }
    }
}

extension DependencyValues {
    
    var diaryListFilterApi: DiaryListFilterClient {
        
        get { self[DiaryListFilterClient.self] }
        set { self[DiaryListFilterClient.self] = newValue }
    }
}
