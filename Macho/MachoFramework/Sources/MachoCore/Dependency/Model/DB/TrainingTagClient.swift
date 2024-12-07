//
//  TrainingTagClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/28.
//

import ComposableArchitecture

public struct TrainingTagClient: Sendable {

    /// 登録しているタグをすべて取得する
    public var fetchAll: @Sendable () async -> [any TrainingTagData]
    
    public init(fetchAll: @escaping @Sendable () async -> [any TrainingTagData]) {
        
        self.fetchAll = fetchAll
    }
}

extension TrainingTagClient: TestDependencyKey {
    
    public static let testValue = TrainingTagClient(fetchAll: unimplemented(placeholder: []))
}

public extension DependencyValues {

    var trainingTagClient: TrainingTagClient {

        get { self[TrainingTagClient.self] }
        set { self[TrainingTagClient.self] = newValue }
    }
}
