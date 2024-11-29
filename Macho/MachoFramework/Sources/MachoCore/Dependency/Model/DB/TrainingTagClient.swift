//
//  TrainingTagClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/28.
//

import ComposableArchitecture

public struct TrainingTagClient {

    /// 登録しているタグをすべて取得する
    public var fetchAll: () async -> [any TrainingTagData]
    
    public init(fetchAll: @escaping () async -> [any TrainingTagData]) {
        
        self.fetchAll = fetchAll
    }
}

extension TrainingTagClient: TestDependencyKey {
    
    public static var testValue = TrainingTagClient(fetchAll: unimplemented(placeholder: []))
}

public extension DependencyValues {

    var trainingTagClient: TrainingTagClient {

        get { self[TrainingTagClient.self] }
        set { self[TrainingTagClient.self] = newValue }
    }
}
