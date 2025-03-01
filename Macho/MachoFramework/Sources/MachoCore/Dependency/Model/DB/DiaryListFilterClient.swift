//
//  DiaryListFilterClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/28.
//

import Combine
import ComposableArchitecture
import Foundation

public struct DiaryListFilterClient: Sendable {
    
    /// 現在設定されている日記リストのフィルターを返す
    public var fetchFilterList: @Sendable () async -> [ConcreteDiaryListFilterData]
    
    /// 日記リストのフィルター追加
    /// - Parameters:
    ///  - filter: 追加するフィルター
    /// - Returns: trueであれば削除成功、そうでなければ失敗
    public var addFilter: @Sendable (_ filter: ConcreteDiaryListFilterData) async -> Bool
    
    /// 日記リストのフィルター削除
    /// - Parameters:
    ///  - targets: 削除対象のフィルター項目
    /// - Returns: trueであれば削除成功、そうでなければ失敗
    public var deleteFilters: @Sendable (_ targets: [ConcreteDiaryListFilterData]) async -> Bool
    
    /// 日記リストのフィルター設定が更新を監視用のPublisherを返す
    public var getFilterListObserver: @Sendable () async -> AnyPublisher<[ConcreteDiaryListFilterData], Never>?
    
    public init(fetchFilterList: @escaping @Sendable () async -> [ConcreteDiaryListFilterData],
                addFilter: @escaping @Sendable (_: ConcreteDiaryListFilterData) async -> Bool,
                deleteFilters: @escaping @Sendable (_: [ConcreteDiaryListFilterData]) async -> Bool,
                getFilterListObserver: @escaping @Sendable () async ->
                AnyPublisher<[ConcreteDiaryListFilterData], Never>?) {
        
        self.fetchFilterList = fetchFilterList
        self.addFilter = addFilter
        self.deleteFilters = deleteFilters
        self.getFilterListObserver = getFilterListObserver
    }
}

extension DiaryListFilterClient: TestDependencyKey {
    
    public static let testValue = DiaryListFilterClient(
        fetchFilterList: unimplemented(placeholder: []),
        addFilter: unimplemented(placeholder: false),
        deleteFilters: unimplemented(placeholder: false),
        getFilterListObserver: unimplemented(placeholder: nil)
    )
}

public extension DependencyValues {
    
    var diaryListFilterClient: DiaryListFilterClient {
        
        get { self[DiaryListFilterClient.self] }
        set { self[DiaryListFilterClient.self] = newValue }
    }
}
