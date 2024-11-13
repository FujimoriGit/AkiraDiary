//
//  TrainingGoalEntity.swift
//
//
//  Created by Daiki Fujimori on 2024/04/13
//

import Foundation
import RealmSwift

public struct TrainingContentEntity: BaseRealmEntity {
    
    public let id: UUID
    /// 種目
    public let trainingType: TrainingTypeEntity?
    /// 目標1セットの回数
    public let goalNumberOfSets: Int
    /// 目標セット数
    public let goalSetCount: Int
    /// 達成した1セットの回数
    public let actualNumberOfSets: Int?
    /// 達成したセット数
    public let actualSetCount: Int?
    /// 開始時間
    public let startTime: Date?
    /// 終了時間
    public let endTime: Date?
    /// トレーニング達成成否
    public var isAchieved: Bool {
        
        guard let actualSetCount,
              let actualNumberOfSets else { return false }
        
        if actualSetCount > goalSetCount ||
            (actualSetCount == goalSetCount && actualNumberOfSets >= goalNumberOfSets) {
            
            return true
        }
        
        return false
    }
    
    public static let executor = RealmObserverExecutor<Self>()
    
    public init(id: UUID,
                trainingType: TrainingTypeEntity,
                goalNumberOfSets: Int,
                goalSetCount: Int,
                actualNumberOfSets: Int?,
                actualSetCount: Int?,
                startTime: Date?,
                endTime: Date?) {
        
        self.id = id
        self.trainingType = trainingType
        self.goalNumberOfSets = goalNumberOfSets
        self.goalSetCount = goalSetCount
        self.actualNumberOfSets = actualNumberOfSets
        self.actualSetCount = actualSetCount
        self.startTime = startTime
        self.endTime = endTime
    }
    
    public init(realmObject: TrainingContentRealmObject) {
        
        id = realmObject.id
        if let trainingType = realmObject.trainingType {
            
            self.trainingType = TrainingTypeEntity(realmObject: trainingType)
        }
        else {
            
            trainingType = nil
        }
        goalNumberOfSets = realmObject.goalNumberOfSets
        goalSetCount = realmObject.goalSetCount
        actualNumberOfSets = realmObject.actualNumberOfSets
        actualSetCount = realmObject.actualSetCount
        startTime = realmObject.startTime
        endTime = realmObject.endTime
    }
    
    public func toRealmObject() -> TrainingContentRealmObject {
        
        return TrainingContentRealmObject(id: id,
                                          trainingType: trainingType?.toRealmObject(),
                                          goalNumberOfSets: goalNumberOfSets,
                                          goalSetCount: goalSetCount,
                                          actualNumberOfSets: actualNumberOfSets,
                                          actualSetCount: actualSetCount,
                                          startTime: startTime,
                                          endTime: endTime)
    }
}

public class TrainingContentRealmObject: Object {
    
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var trainingType: TrainingTypeRealmObject?
    @Persisted var goalNumberOfSets: Int
    @Persisted var goalSetCount: Int
    @Persisted var actualNumberOfSets: Int?
    @Persisted var actualSetCount: Int?
    @Persisted var startTime: Date?
    @Persisted var endTime: Date?
    
    convenience init(id: UUID,
                     trainingType: TrainingTypeRealmObject?,
                     goalNumberOfSets: Int,
                     goalSetCount: Int,
                     actualNumberOfSets: Int?,
                     actualSetCount: Int?,
                     startTime: Date?,
                     endTime: Date?) {
        
        self.init()
        
        self.id = id
        self.trainingType = trainingType
        self.goalNumberOfSets = goalNumberOfSets
        self.goalSetCount = goalSetCount
        self.actualNumberOfSets = actualNumberOfSets
        self.actualSetCount = actualSetCount
        self.startTime = startTime
        self.endTime = endTime
    }
}
