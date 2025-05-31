//
//  DiaryEntityClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/22.
//

import Combine
import Dependencies
import Foundation

public struct DiaryEntityClient: Sendable {
    
    public let fetchAll: @Sendable () async -> [DiaryData]
    public let add: @Sendable (DiaryData) async -> Bool
    public let deleteDiary: @Sendable (_ id: UUID) async -> Bool
    public let getDiaryObserver: @Sendable () async -> AnyPublisher<[DiaryData], Never>?
    
    public init(fetchAll: @escaping @Sendable () async -> [DiaryData],
                add: @escaping @Sendable (DiaryData) async -> Bool,
                deleteDiary: @escaping @Sendable (_: UUID) async -> Bool,
                getDiaryObserver: @escaping @Sendable () async -> AnyPublisher<[DiaryData], Never>?) {
        
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
