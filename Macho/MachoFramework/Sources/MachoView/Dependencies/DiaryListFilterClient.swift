//
//  DiaryListFilterClient.swift
//
//
//  Created by 佐藤汰一 on 2024/08/10.
//

import Combine
import ComposableArchitecture
import Foundation
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
    
    static var liveValue = createCustomValue(RealmAccessor()) {
        
        let executor = DiaryListFilterEntity.executor
        executor.startObservation(RealmAccessor())
        return executor.getPublisher().map { convertFilterEntityToItem($0) }.eraseToAnyPublisher()
    }
    
    static var testValue = DiaryListFilterClient { _ in
        
        return true
    } updateFilter: { _ in
        
        return true
    } deleteFilters: { _ in
        
        return true
    } fetchFilterList: {
    
        return [DiaryListFilterItem(target: .achievement, filterItemId: UUID(), value: "達成していない")]
    } getFilterListObserver: {
        
        return PassthroughSubject<[DiaryListFilterItem], Never>().eraseToAnyPublisher()
    }
    
    static func createCustomValue(_ realm: RealmAccessible,
                                  observer: (() -> AnyPublisher<[DiaryListFilterItem], Never>)? = nil)
    -> DiaryListFilterClient {
        
        return DiaryListFilterClient {
            
            return await insertFilter(realm, filter: $0)
        } updateFilter: {
            
            return await updateFilterValue(realm, filter: $0)
        } deleteFilters: {
            
            return await deleteFilters(realm, targets: $0)
        } fetchFilterList: {
            
            return await fetchFilters(realm)
        } getFilterListObserver: {
            
            return observer?() ?? PassthroughSubject<[DiaryListFilterItem], Never>().eraseToAnyPublisher()
        }
    }
}

private extension DiaryListFilterClient {
    
    // 指定のフィルターの保存
    static func insertFilter(_ realm: RealmAccessible = RealmAccessor(), filter: DiaryListFilterItem) async -> Bool {
        
        return await realm.insert(records: [
            DiaryListFilterEntity(id: filter.id,
                                  filterTarget: filter.target.rawValue,
                                  filterId: filter.filterItemId,
                                  filterValue: filter.value)
        ])
    }
    
    // 指定のフィルターの更新
    static func updateFilterValue(_ realm: RealmAccessible = RealmAccessor(),
                                  filter: DiaryListFilterItem) async -> Bool {
        
        // filterValueを更新する辞書を生成
        let updateValue = ["id": filter.id, "filterValue": filter.value]
        return await realm.update(type: DiaryListFilterEntity.self, value: updateValue)
    }
    
    // 指定のフィルターの削除
    static func deleteFilters(_ realm: RealmAccessible = RealmAccessor(),
                              targets: [DiaryListFilterItem]) async -> Bool {
        
        return await realm.delete { (entity: DiaryListFilterEntity) in
            
            return targets.contains {
                
                return $0.target.rawValue == entity.filterTarget && $0.value == entity.filterValue
            }
        }
    }
    
    // 現在登録しているフィルターの取得
    static func fetchFilters(_ realm: RealmAccessible = RealmAccessor()) async -> [DiaryListFilterItem] {
        
        return convertFilterEntityToItem(await realm.read(where: nil))
    }
    
    static func convertFilterEntityToItem(_ entities: [DiaryListFilterEntity]) -> [DiaryListFilterItem] {
        
        return entities.compactMap {
            
            guard let target = DiaryListFilterTarget(rawValue: $0.filterTarget) else { return nil }
            return DiaryListFilterItem(target: target, filterItemId: $0.filterId, value: $0.filterValue)
        }
    }
}

extension DependencyValues {
    
    var diaryListFilterApi: DiaryListFilterClient {
        
        get { self[DiaryListFilterClient.self] }
        set { self[DiaryListFilterClient.self] = newValue }
    }
}
