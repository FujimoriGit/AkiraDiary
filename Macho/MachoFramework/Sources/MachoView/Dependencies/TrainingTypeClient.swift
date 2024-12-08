//
//  TrainingTypeClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/10/26.
//

import Combine
import ComposableArchitecture
import Foundation
import RealmHelper

struct TrainingTypeClient {

    /// 種目の登録
    var add: (_ trainingTypeName: String) async -> Bool
    /// 種目の更新
    var update: (TrainingTypeData) async -> Bool
    /// 登録されているすべてのトレーニング種目を取得する
    var fetchAll: () async -> [TrainingTypeEntity]
    
    var getPublisher: () -> AnyPublisher<[TrainingTypeData], Never>
}

extension TrainingTypeClient: DependencyKey {
    
    static var liveValue: TrainingTypeClient = .createCustomValue {
        
        let executor = TrainingTypeEntity.executor
        executor.startObservation()
        return executor.getPublisher().eraseToAnyPublisher()
    }
    
    static var previewValue = TrainingTypeClient { _ in
        
        return true
    } update: { _ in
        
       return true
    } fetchAll: {
        
        let types = [
            "もりもり",
            "トレーニング",
            "Swift",
            "iOS開発",
            "SwiftUI",
            "UIKit",
            "WWDC",
            "Python",
            "JavaScript",
            "PHP",
            "Ruby",
            "Flutter",
            "Dart",
            "Android",
            "iPhone",
            "あきら",
            "たいち"
        ]
        
        return types.map { TrainingTypeEntity(id: UUID(), name: $0) }
    } getPublisher: {
        
        return PassthroughSubject<[TrainingTypeData], Never>().eraseToAnyPublisher()
    }
}

private extension TrainingTypeClient {
    
    static func createCustomValue(_ realm: RealmAccessible = RealmAccessor(),
                                  publisher: (() -> AnyPublisher<[TrainingTypeData], Never>)? = nil) -> TrainingTypeClient {
        
        TrainingTypeClient {
            
            return await add(realm, trainingTypeName: $0)
        } update: {
            
            return await update(realm, trainingType: $0)
        } fetchAll: {
            
            return await fetchAll(realm)
        } getPublisher: {
            
            return publisher?() ?? PassthroughSubject<[TrainingTypeData], Never>().eraseToAnyPublisher()
        }
    }

    static func add(_ realm: RealmAccessible = RealmAccessor(), trainingTypeName: String) async -> Bool {
        
        let types = await fetchAll(realm)
        if types.contains(where: { $0.name == trainingTypeName }) {
            
            logger.error("already added.")
            return false
        }
        
        let trainingType = TrainingTypeEntity(id: UUID(), name: trainingTypeName)
        
        return await realm.insert(records: [trainingType])
    }
    
    static func update(_ realm: RealmAccessible = RealmAccessor(), trainingType: TrainingTypeData) async -> Bool {
        
        let value: [String: Any] = ["id": trainingType.id, "name": trainingType.name]
        
        return await realm.update(type: TrainingTypeEntity.self, value: value)
    }
    
    static func fetchAll(_ realm: RealmAccessible) async -> [TrainingTypeEntity] {

        return await realm.read(where: nil)
    }
}

extension DependencyValues {

    var trainingTypeApi: TrainingTypeClient {

        get { self[TrainingTypeClient.self] }
        set { self[TrainingTypeClient.self] = newValue }
    }
}
