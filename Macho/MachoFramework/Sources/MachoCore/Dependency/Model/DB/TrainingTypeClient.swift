//
//  TrainingTypeClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/28.
//

import Combine
import ComposableArchitecture

public struct TrainingTypeClient: Sendable {

    /// 登録されているすべてのトレーニング種目を取得する
    public var fetchAllType: @Sendable () async -> [ConcreteTrainingTypeData]
    /// 新しいトレーニング種目を追加する
    public var add: @Sendable (ConcreteTrainingTypeData) async -> Bool
    /// タグの監視
    public var getObserve: @Sendable () async -> AnyPublisher<[ConcreteTrainingTypeData], Never>?
    
    public init(
        fetchAllType: @escaping @Sendable () async -> [ConcreteTrainingTypeData],
        add: @escaping @Sendable (ConcreteTrainingTypeData) async -> Bool,
        getObserve: @escaping @Sendable () async -> AnyPublisher<[ConcreteTrainingTypeData], Never>?
    ) {
        
        self.fetchAllType = fetchAllType
        self.add = add
        self.getObserve = getObserve
    }
}

extension TrainingTypeClient: TestDependencyKey {
    
    public static let testValue = TrainingTypeClient(
        fetchAllType: unimplemented(placeholder: []),
        add: unimplemented(placeholder: false),
        getObserve: unimplemented(placeholder: nil)
    )
}

public extension DependencyValues {

    var trainingTypeClient: TrainingTypeClient {

        get { self[TrainingTypeClient.self] }
        set { self[TrainingTypeClient.self] = newValue }
    }
}
