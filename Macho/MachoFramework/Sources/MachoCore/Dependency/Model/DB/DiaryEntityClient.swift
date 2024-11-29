//
//  DiaryEntityClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/22.
//

import Combine
import ComposableArchitecture
import Foundation

public struct DiaryEntityClient {
    
    public let fetchAll: () async -> [any DiaryData]
    public let deleteDiary: (_ id: UUID) async -> Bool
    public let getDiaryObserver: () -> AnyPublisher<[any DiaryData], Never>
    
    public init(fetchAll: @escaping () async -> [any DiaryData],
                deleteDiary: @escaping (_: UUID) async -> Bool,
                getDiaryObserver: @escaping () -> AnyPublisher<[any DiaryData], Never>) {
        
        self.fetchAll = fetchAll
        self.deleteDiary = deleteDiary
        self.getDiaryObserver = getDiaryObserver
    }
}

extension DiaryEntityClient: TestDependencyKey {
    
    public static var testValue = DiaryEntityClient(
        fetchAll: unimplemented(placeholder: []),
        deleteDiary: unimplemented(placeholder: false),
        getDiaryObserver: unimplemented(placeholder: PassthroughSubject().eraseToAnyPublisher())
    )
}

public extension DependencyValues {
    
    var diaryEntityClient: DiaryEntityClient {
        
        get { self[DiaryEntityClient.self] }
        set { self[DiaryEntityClient.self] = newValue }
    }
}
