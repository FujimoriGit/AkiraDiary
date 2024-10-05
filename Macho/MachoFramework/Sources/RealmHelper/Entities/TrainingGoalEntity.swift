//
//  TrainingGoalEntity.swift
//
//  
//  Created by Daiki Fujimori on 2024/04/13
//

import Foundation
import RealmSwift

public struct TrainingGoalEntity: BaseRealmEntity {
    
    public let id: UUID
    /// 目標種目
    public let goalType: TrainingTypeEntity?
    /// 1セットの回数
    public let numberOfSets: Int
    /// セット数
    public let setCount: Int
    /// 開始時間
    public let startTime: Date?
    /// 終了時間
    public let endTime: Date?
    /// トレーニング達成成否
    public let isSuccess: Bool?
    
    public static let executor = RealmObserverExecutor<Self>()
    
    public init(id: UUID, goalType: TrainingTypeEntity, numberOfSets: Int,
                setCount: Int, startTime: Date?, endTime: Date?, isSuccess: Bool?) {
        
        self.id = id
        self.goalType = goalType
        self.numberOfSets = numberOfSets
        self.setCount = setCount
        self.startTime = startTime
        self.endTime = endTime
        self.isSuccess = isSuccess
    }
    
    public init(realmObject: TrainingGoalRealmObject) {
        
        id = realmObject.id
        
        if let goalType = realmObject.goalType {
            
            self.goalType = TrainingTypeEntity(realmObject: goalType)
        }
        else {
            
            self.goalType = nil
        }
        numberOfSets = realmObject.numberOfSets
        setCount = realmObject.setCount
        startTime = realmObject.startTime
        endTime = realmObject.endTime
        isSuccess = realmObject.isSuccess
    }
    
    public func toRealmObject() -> TrainingGoalRealmObject {
        
        return TrainingGoalRealmObject(id: id, goalType: goalType?.toRealmObject(), numberOfSets: numberOfSets,
                                       setCount: setCount, startTime: startTime, endTime: endTime,
                                       isSuccess: isSuccess)
    }
}

public class TrainingGoalRealmObject: Object {
    
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var goalType: TrainingTypeRealmObject?
    @Persisted var numberOfSets: Int
    @Persisted var setCount: Int
    @Persisted var startTime: Date?
    @Persisted var endTime: Date?
    @Persisted var isSuccess: Bool?
    
    convenience init(id: UUID, goalType: TrainingTypeRealmObject?, numberOfSets: Int,
                     setCount: Int, startTime: Date?, endTime: Date?, isSuccess: Bool?) {
        
        self.init()
        
        self.id = id
        self.goalType = goalType
        self.numberOfSets = numberOfSets
        self.setCount = setCount
        self.startTime = startTime
        self.endTime = endTime
        self.isSuccess = isSuccess
    }
}
