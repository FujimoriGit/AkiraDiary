//
//  TrainingTypeClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/28.
//

import ComposableArchitecture

public struct TrainingTypeClient {

    /// 登録されているすべてのトレーニング種目を取得する
    public var fetchAllType: () async -> [any TrainingTypeData]
    
    public init(fetchAllType: @escaping () async -> [any TrainingTypeData]) {
        
        self.fetchAllType = fetchAllType
    }
}

extension TrainingTypeClient: TestDependencyKey {
    
    public static var testValue = TrainingTypeClient(fetchAllType: unimplemented(placeholder: []))
}

public extension DependencyValues {

    var trainingTypeClient: TrainingTypeClient {

        get { self[TrainingTypeClient.self] }
        set { self[TrainingTypeClient.self] = newValue }
    }
}
