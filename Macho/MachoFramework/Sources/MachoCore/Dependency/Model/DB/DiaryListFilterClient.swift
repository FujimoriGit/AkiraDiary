//
//  DiaryListFilterClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/28.
//

import Combine
import ComposableArchitecture
import Foundation

public struct DiaryListFilterClient {
    
    /// 現在設定されている日記リストのフィルターを返す
    public var fetchFilterList: () async -> [any DiaryListFilterData]
    
    /// 日記リストのフィルター追加
    /// - Parameters:
    ///  - filter: 追加するフィルター
    /// - Returns: trueであれば削除成功、そうでなければ失敗
    public var addFilter: (_ filter: any DiaryListFilterData) async -> Bool
    
    /// 日記リストのフィルター更新
    /// - Parameters:
    ///  - filter: 更新後のフィルター
    /// - Returns: trueであれば削除成功、そうでなければ失敗
    public var updateFilter: (_ filter: any DiaryListFilterData) async -> Bool
    
    /// 日記リストのフィルター削除
    /// - Parameters:
    ///  - targets: 削除対象のフィルター項目
    /// - Returns: trueであれば削除成功、そうでなければ失敗
    public var deleteFilters: (_ targets: [any DiaryListFilterData]) async -> Bool
    
    /// 日記リストのフィルター設定が更新を監視用のPublisherを返す
    public var getFilterListObserver: () async -> AnyPublisher<[any DiaryListFilterData], Never>?
    
    public init(fetchFilterList: @escaping () async -> [any DiaryListFilterData],
                addFilter: @escaping (_: any DiaryListFilterData) async -> Bool,
                updateFilter: @escaping (_: any DiaryListFilterData) async -> Bool,
                deleteFilters: @escaping (_: [any DiaryListFilterData]) async -> Bool,
                getFilterListObserver: @escaping () async -> AnyPublisher<[any DiaryListFilterData], Never>?) {
        
        self.fetchFilterList = fetchFilterList
        self.addFilter = addFilter
        self.updateFilter = updateFilter
        self.deleteFilters = deleteFilters
        self.getFilterListObserver = getFilterListObserver
    }
}

extension DiaryListFilterClient: TestDependencyKey {
    
    public static var testValue = DiaryListFilterClient(
        fetchFilterList: unimplemented(placeholder: []),
        addFilter: unimplemented(placeholder: false),
        updateFilter: unimplemented(placeholder: false),
        deleteFilters: unimplemented(placeholder: false),
        getFilterListObserver: unimplemented(placeholder: PassthroughSubject().eraseToAnyPublisher())
    )
}

public extension DependencyValues {
    
    var diaryListFilterClient: DiaryListFilterClient {
        
        get { self[DiaryListFilterClient.self] }
        set { self[DiaryListFilterClient.self] = newValue }
    }
}
