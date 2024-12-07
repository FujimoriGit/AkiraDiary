//
//  TrainingTypeClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/28.
//

import ComposableArchitecture

public struct TrainingTypeClient: Sendable {

    /// 登録されているすべてのトレーニング種目を取得する
    public var fetchAllType: @Sendable () async -> [any TrainingTypeData]
    
    public init(fetchAllType: @escaping @Sendable () async -> [any TrainingTypeData]) {
        
        self.fetchAllType = fetchAllType
    }
}

extension TrainingTypeClient: TestDependencyKey {
    
    public static let testValue = TrainingTypeClient(fetchAllType: unimplemented(placeholder: []))
}

public extension DependencyValues {

    var trainingTypeClient: TrainingTypeClient {

        get { self[TrainingTypeClient.self] }
        set { self[TrainingTypeClient.self] = newValue }
    }
}
