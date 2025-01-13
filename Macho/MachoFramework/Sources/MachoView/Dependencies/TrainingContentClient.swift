//
//  TrainingContentClient.swift
//  MachoFramework
//  
//  Created by Daiki Fujimori on 2024/11/02
//  

import Combine
import ComposableArchitecture
import Foundation
import RealmHelper

struct TrainingContentClient {

    /// 目標の登録
    var addGoals: ([Goal]) async -> Bool
    /// 目標の更新
    var updateGoal: (Goal) async -> Bool
    /// 登録している目標をすべて取得する
    var fetchAll: () async -> [TrainingContentData]
    /// 監視用のPublisherを返す
    var getTrainingGoalPublisher: () -> AnyPublisher<[TrainingContentData], Never>
}

extension TrainingContentClient: DependencyKey {

    static var liveValue: TrainingContentClient = .createCustomValue()

    static var previewValue = TrainingContentClient { _ in
        
        return true
    } updateGoal: { _ in
        
        return true
    } fetchAll: {
        
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
        
        return goalNames.map { TrainingContentEntity(id: UUID(),
                                                     trainingType: TrainingTypeEntity(id: UUID(), name: $0),
                                                     goalNumberOfSets: Int.random(in: 8...15),
                                                     goalSetCount: Int.random(in: 2...5),
                                                     actualNumberOfSets: nil,
                                                     actualSetCount: nil)
        }
    } getTrainingGoalPublisher: {
        
        return PassthroughSubject<[TrainingContentEntity], Never>().eraseToAnyPublisher()
    }
    
    static func createCustomValue(
        _ realm: RealmAccessible = RealmAccessor(),
        publisher: (() -> AnyPublisher<[TrainingContentEntity], Never>)? = nil
    ) -> TrainingContentClient {
        
        return TrainingContentClient {
            
            return await addGoals(realm, goals: $0)
        } updateGoal: {
            
            return await updateGoal(realm, goal: $0)
        } fetchAll: {
            
            return await fetchAllGoal(realm)
        } getTrainingGoalPublisher: {
            
            return publisher?() ?? PassthroughSubject<[TrainingContentEntity], Never>().eraseToAnyPublisher()
        }
    }
}

private extension TrainingContentClient {

    static func fetchAllGoal(_ realm: RealmAccessible) async -> [TrainingContentEntity] {

        return await realm.read(where: nil)
    }
    
    /// DBに目標を追加します.
    static func addGoals(_ realm: RealmAccessible = RealmAccessor(),
                         goals: [Goal]) async -> Bool {
        
        if goals.isEmpty {
            
            logger.error("tags is empty.")
            return false
        }
        
        let records = goals.map {
            
            return TrainingContentEntity(id: $0.id,
                                         trainingType: $0.trainingType,
                                         goalNumberOfSets: $0.numberOfSets,
                                         goalSetCount: $0.setCount,
                                         actualNumberOfSets: nil,
                                         actualSetCount: nil)
        }
        
        return await realm.insert(records: records)
    }
    
    static func updateGoal(_ realm: RealmAccessible = RealmAccessor(), goal: Goal) async -> Bool {
        
        let value: [String: Any] = ["id": goal.id, "trainingType": goal.trainingType]
        
        return await realm.update(type: TrainingContentEntity.self, value: value)
    }
}

extension DependencyValues {

    var trainingGoalApi: TrainingContentClient {

        get { self[TrainingContentClient.self] }
        set { self[TrainingContentClient.self] = newValue }
    }
}
