//
//  RealmFetchClient.swift
//
//  
//  Created by Daiki Fujimori on 2024/05/03
//  
//

import ComposableArchitecture
import Foundation
import RealmHelper

struct RealmFetchClient {
    
    var fetchTrainingTag: (TrainingTagEntity.Type) async throws -> [TrainingTagEntity]
    
    var fetchTrainingGoal: (TrainingGoalEntity.Type) async throws -> [TrainingGoalEntity]
}

extension RealmFetchClient: DependencyKey {
    
    static let liveValue = Self(fetchTrainingTag: { entityType in
        
        let entities = await RealmAccessor().read(type: entityType.self)
        
        return entities
        
    }, fetchTrainingGoal: { entityType in
        
        let entities = await RealmAccessor().read(type: entityType.self)
        
        return entities
    })
    
    static let previewValue = Self(fetchTrainingTag: { _ in
        
        let tagNames = ["もりもり", "トレーニング", "Swift", "iOS開発", "SwiftUI", "UIKit", "WWDC", "Python",
                       "JavaScript", "PHP", "Ruby", "Flutter", "Dart", "Android", "iPhone", "あきら", "たいち"]
        
        return tagNames.map { TrainingTagEntity(id: UUID(), tagName: $0) }
        
    }, fetchTrainingGoal: { _ in
        
        let goalNames = ["クランチ", "懸垂", "ランニング", "スクワット", "腕立て", "UIKit", "WWDC", "Python",
                         "JavaScript", "PHP", "Ruby", "Flutter", "Dart", "Android", "iPhone", "あきら", "たいち"]
        
        return goalNames.map { TrainingGoalEntity(id: UUID(),
                                                  goalName: $0,
                                                  numberOfSets: Int.random(in: 8...15),
                                                  setCount: Int.random(in: 2...5))
        }
    })
}

extension DependencyValues {
    
    var realmFetch: RealmFetchClient {
        
        get { self[RealmFetchClient.self] }
        set { self[RealmFetchClient.self] = newValue }
    }
}
