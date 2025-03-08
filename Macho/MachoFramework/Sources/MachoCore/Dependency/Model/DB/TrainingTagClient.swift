//
//  TrainingTagClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/28.
//

import Combine
import ComposableArchitecture

public struct TrainingTagClient: Sendable {

    /// 登録しているタグをすべて取得する
    public var fetchAll: @Sendable () async -> [TrainingTagData]
    /// 新しいタグを追加する
    public var add: @Sendable (TrainingTagData) async -> Bool
    /// 既存タグを更新する
    public var update: @Sendable (TrainingTagData) async -> Bool
    /// タグの監視
    public var getObserve: @Sendable () async -> AnyPublisher<[TrainingTagData], Never>?
    
    public init(
        fetchAll: @escaping @Sendable () async -> [TrainingTagData],
        add: @escaping @Sendable (TrainingTagData) async -> Bool,
        update: @escaping @Sendable (TrainingTagData) async -> Bool,
        getObserve: @escaping @Sendable () async -> AnyPublisher<[TrainingTagData], Never>?
    ) {
        
        self.fetchAll = fetchAll
        self.add = add
        self.update = update
        self.getObserve = getObserve
    }
}

extension TrainingTagClient: TestDependencyKey {
    
    public static let testValue = TrainingTagClient(
        fetchAll: unimplemented(placeholder: []),
        add: unimplemented(placeholder: false),
        update: unimplemented(placeholder: false),
        getObserve: unimplemented(placeholder: nil)
    )
}

public extension DependencyValues {

    var trainingTagClient: TrainingTagClient {

        get { self[TrainingTagClient.self] }
        set { self[TrainingTagClient.self] = newValue }
    }
}
