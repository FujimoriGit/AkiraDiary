//
//  MachoFramework
//
//  TrainingContentClient.swift
//
//  Created by stotic-dev on 2025/02/24
//  Copyright © Macho All rights reserved.
//

import Combine
import ComposableArchitecture

public struct TrainingContentClient: Sendable {

    /// 目標の登録
    public var addGoals: @Sendable (ConcreteTrainingContentData) async -> Bool
    /// 目標の更新
    public var updateGoal: @Sendable (ConcreteTrainingContentData) async -> Bool
    /// 登録している目標をすべて取得する
    public var fetchAll: @Sendable () async -> [ConcreteTrainingContentData]
    /// 監視用のPublisherを返す
    public var getTrainingGoalPublisher: @Sendable () async -> AnyPublisher<[ConcreteTrainingContentData], Never>?
    
    public init(
        addGoals: @Sendable @escaping (ConcreteTrainingContentData) async -> Bool,
        updateGoal: @Sendable @escaping (ConcreteTrainingContentData) async -> Bool,
        fetchAll: @Sendable @escaping () async -> [ConcreteTrainingContentData],
        getTrainingGoalPublisher: @Sendable @escaping () async -> AnyPublisher<[ConcreteTrainingContentData], Never>?
    ) {
        
        self.addGoals = addGoals
        self.updateGoal = updateGoal
        self.fetchAll = fetchAll
        self.getTrainingGoalPublisher = getTrainingGoalPublisher
    }
}

extension TrainingContentClient: TestDependencyKey {
    
    public static var testValue: TrainingContentClient {
        return .init(
            addGoals: unimplemented(placeholder: false),
            updateGoal: unimplemented(placeholder: false),
            fetchAll: unimplemented(placeholder: []),
            getTrainingGoalPublisher: unimplemented(placeholder: nil)
        )
    }
}

public extension DependencyValues {

    var trainingContentClient: TrainingContentClient {

        get { self[TrainingContentClient.self] }
        set { self[TrainingContentClient.self] = newValue }
    }
}
