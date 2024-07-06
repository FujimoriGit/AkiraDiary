//
//  TrainingGoalEntity.swift
//
//  
//  Created by Daiki Fujimori on 2024/04/13
//  
//

import RealmSwift
import Foundation

public struct TrainingGoalEntity: BaseRealmEntity {
    
    public let id: UUID
    public let goalName: String
    /// 1セットの回数
    public let numberOfSets: Int
    /// セット数
    public let setCount: Int
    
    public static let executor = RealmObserverExecutor<Self>()
    
    public init(id: UUID, goalName: String, numberOfSets: Int, setCount: Int) {
        
        self.id = id
        self.goalName = goalName
        self.numberOfSets = numberOfSets
        self.setCount = setCount
    }
    
    public init(realmObject: TrainingGoalRealmObject) {
        
        id = realmObject.id
        goalName = realmObject.goalName
        numberOfSets = realmObject.numberOfSets
        setCount = realmObject.setCount
    }
    
    public func toRealmObject() -> TrainingGoalRealmObject {
        
        return TrainingGoalRealmObject(id: id, goalName: goalName, numberOfSets: numberOfSets, setCount: setCount)
    }
}

public class TrainingGoalRealmObject: Object {
    
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var goalName: String
    @Persisted var numberOfSets: Int
    @Persisted var setCount: Int
    
    convenience init(id: UUID, goalName: String, numberOfSets: Int, setCount: Int) {
        
        self.init()
        
        self.id = id
        self.goalName = goalName
        self.numberOfSets = numberOfSets
        self.setCount = setCount
    }
}
