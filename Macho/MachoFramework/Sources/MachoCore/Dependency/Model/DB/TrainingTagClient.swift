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
    public var fetchAll: @Sendable () async -> [ConcreteTrainingTagData]
    /// 新しいタグを追加する
    public var add: @Sendable (ConcreteTrainingTagData) async -> Bool
    /// 既存タグを更新する
    public var update: @Sendable (ConcreteTrainingTagData) async -> Bool
    /// タグの監視
    public var getObserve: @Sendable () async -> AnyPublisher<[ConcreteTrainingTagData], Never>?
    
    public init(
        fetchAll: @escaping @Sendable () async -> [ConcreteTrainingTagData],
        add: @escaping @Sendable (ConcreteTrainingTagData) async -> Bool,
        update: @escaping @Sendable (ConcreteTrainingTagData) async -> Bool,
        getObserve: @escaping @Sendable () async -> AnyPublisher<[ConcreteTrainingTagData], Never>?
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
