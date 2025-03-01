//
//  DiaryEntityClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/22.
//

import Combine
import ComposableArchitecture
import Foundation

public struct DiaryEntityClient: Sendable {
    
    public let fetchAll: @Sendable () async -> [ConcreteDiaryData]
    public let add: @Sendable (ConcreteDiaryData) async -> Bool
    public let deleteDiary: @Sendable (_ id: UUID) async -> Bool
    public let getDiaryObserver: @Sendable () async -> AnyPublisher<[ConcreteDiaryData], Never>?
    
    public init(fetchAll: @escaping @Sendable () async -> [ConcreteDiaryData],
                add: @escaping @Sendable (ConcreteDiaryData) async -> Bool,
                deleteDiary: @escaping @Sendable (_: UUID) async -> Bool,
                getDiaryObserver: @escaping @Sendable () async -> AnyPublisher<[ConcreteDiaryData], Never>?) {
        
        self.fetchAll = fetchAll
        self.add = add
        self.deleteDiary = deleteDiary
        self.getDiaryObserver = getDiaryObserver
    }
}

extension DiaryEntityClient: TestDependencyKey {
    
    public static let testValue = DiaryEntityClient(
        fetchAll: unimplemented(placeholder: []),
        add: unimplemented(placeholder: false),
        deleteDiary: unimplemented(placeholder: false),
        getDiaryObserver: unimplemented(placeholder: nil)
    )
}

public extension DependencyValues {
    
    var diaryEntityClient: DiaryEntityClient {
        
        get { self[DiaryEntityClient.self] }
        set { self[DiaryEntityClient.self] = newValue }
    }
}
