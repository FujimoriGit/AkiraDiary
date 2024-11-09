//
//  TrainingGoalClient.swift
//  MachoFramework
//  
//  Created by Daiki Fujimori on 2024/11/02
//  

import Combine
import ComposableArchitecture
import Foundation
import RealmHelper

struct TrainingGoalClient {

    /// 登録している目標をすべて取得する
    var fetchAll: () async -> [TrainingGoalEntity]
    /// 監視用のPublisherを返す
    var getTrainingGoalPublisher: () -> AnyPublisher<[TrainingGoalEntity], Never>
}

extension TrainingGoalClient: DependencyKey {

    static var liveValue: TrainingGoalClient = .createCustomValue()

    static var previewValue = TrainingGoalClient {
        
        let goalNames = [
            "クランチ",
            "懸垂",
            "ランニング",
            "スクワット",
            "腕立て",
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
        
        return goalNames.map { TrainingGoalEntity(id: UUID(),
                                                  goalType: TrainingTypeEntity(id: UUID(), name: $0),
                                                  numberOfSets: Int.random(in: 8...15),
                                                  setCount: Int.random(in: 2...5),
                                                  startTime: nil,
                                                  endTime: nil)
        }
    } getTrainingGoalPublisher: {
        
        return PassthroughSubject<[TrainingGoalEntity], Never>().eraseToAnyPublisher()
    }
}

private extension TrainingGoalClient {
    
    static func createCustomValue(_ realm: RealmAccessible = RealmAccessor(),
                                  publisher: (() -> AnyPublisher<[TrainingGoalEntity], Never>)? = nil) -> TrainingGoalClient {

        return TrainingGoalClient {
            
            return await fetchAllGoal(realm)
        } getTrainingGoalPublisher: {
            
            return publisher?() ?? PassthroughSubject<[TrainingGoalEntity], Never>().eraseToAnyPublisher()
        }
    }

    static func fetchAllGoal(_ realm: RealmAccessible) async -> [TrainingGoalEntity] {

        return await realm.read(where: nil)
    }
}

extension DependencyValues {

    var trainingGoalApi: TrainingGoalClient {

        get { self[TrainingGoalClient.self] }
        set { self[TrainingGoalClient.self] = newValue }
    }
}
