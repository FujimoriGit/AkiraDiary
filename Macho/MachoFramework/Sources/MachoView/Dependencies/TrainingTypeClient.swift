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
    
    /// 登録されているすべてのトレーニング種目を取得する
    var fetchAllType: () async -> [TrainingTypeEntity]
    
    /// トレーニング種目のEntityの変更を監視するPublisherを取得する
    var getObserver: () -> AnyPublisher<[TrainingTypeEntity], Never>
}

extension TrainingTypeClient: DependencyKey {
    
    static var liveValue: TrainingTypeClient = .createCustomValue {
        
        let executor = TrainingTypeEntity.executor
        executor.startObservation()
        return executor.getPublisher()
    }
    
    static func createCustomValue(
        _ realm: RealmAccessible = RealmAccessor(),
        observer: (() -> AnyPublisher<[TrainingTypeEntity], Never>)? = nil
    ) -> TrainingTypeClient {
        
        return TrainingTypeClient {
            
            await fetchAllType(realm)
        } getObserver: {
            
            return observer?() ?? PassthroughSubject().eraseToAnyPublisher()
        }
    }
}

private extension TrainingTypeClient {
    
    static func fetchAllType(_ realm: RealmAccessible) async -> [TrainingTypeEntity] {
        
        return await realm.read(where: nil)
    }
}

extension DependencyValues {
    
    var trainingTypeApi: TrainingTypeClient {
        
        get { self[TrainingTypeClient.self] }
        set { self[TrainingTypeClient.self] = newValue }
    }
}
