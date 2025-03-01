//
//  TrainingGoalEntity.swift
//
//
//  Created by Daiki Fujimori on 2024/04/13
//

import Foundation
import MachoCore
import RealmHelper
import RealmSwift

public struct TrainingContentEntity: BaseRealmEntity, TrainingContentData {
    
    public typealias TrainingType = TrainingTypeEntity
    
    public let id: UUID
    /// 種目
    public var trainingType: TrainingType?
    /// 目標1セットの回数
    public let goalNumberOfSets: Int
    /// 目標セット数
    public let goalSetCount: Int
    /// 達成した1セットの回数
    public let actualNumberOfSets: Int?
    /// 達成したセット数
    public let actualSetCount: Int?
    
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
    
    public init(id: UUID,
                trainingType: TrainingTypeEntity,
                goalNumberOfSets: Int,
                goalSetCount: Int,
                actualNumberOfSets: Int?,
                actualSetCount: Int?) {
        
        self.id = id
        self.trainingType = trainingType
        self.goalNumberOfSets = goalNumberOfSets
        self.goalSetCount = goalSetCount
        self.actualNumberOfSets = actualNumberOfSets
        self.actualSetCount = actualSetCount
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
    }
    
    init(_ data: some TrainingContentData) {
        
        id = data.id
        if let trainingType = data.trainingType {
            
            self.trainingType = TrainingTypeEntity(trainingType)
        }
        else {
            
            trainingType = nil
        }
        goalNumberOfSets = data.goalNumberOfSets
        goalSetCount = data.goalSetCount
        actualNumberOfSets = data.actualNumberOfSets
        actualSetCount = data.actualSetCount
    }
    
    public func toRealmObject() -> TrainingContentRealmObject {
        
        guard let trainingTypeEntity = trainingType else {
            
            assertionFailure("Invalid entity type: \(type(of: trainingType))")
            return TrainingContentRealmObject(id: id,
                                              trainingType: nil,
                                              goalNumberOfSets: goalNumberOfSets,
                                              goalSetCount: goalSetCount,
                                              actualNumberOfSets: actualNumberOfSets,
                                              actualSetCount: actualSetCount)
        }
        
        return TrainingContentRealmObject(id: id,
                                          trainingType: trainingTypeEntity.toRealmObject(),
                                          goalNumberOfSets: goalNumberOfSets,
                                          goalSetCount: goalSetCount,
                                          actualNumberOfSets: actualNumberOfSets,
                                          actualSetCount: actualSetCount)
    }
}

public class TrainingContentRealmObject: Object {
    
    @Persisted(primaryKey: true)
    var id: UUID
    @Persisted var trainingType: TrainingTypeRealmObject?
    @Persisted var goalNumberOfSets: Int
    @Persisted var goalSetCount: Int
    @Persisted var actualNumberOfSets: Int?
    @Persisted var actualSetCount: Int?
    
    convenience init(id: UUID,
                     trainingType: TrainingTypeRealmObject?,
                     goalNumberOfSets: Int,
                     goalSetCount: Int,
                     actualNumberOfSets: Int?,
                     actualSetCount: Int?) {
        
        self.init()
        
        self.id = id
        self.trainingType = trainingType
        self.goalNumberOfSets = goalNumberOfSets
        self.goalSetCount = goalSetCount
        self.actualNumberOfSets = actualNumberOfSets
        self.actualSetCount = actualSetCount
    }
}

extension ConcreteTrainingContentData {
    
    init(entity: TrainingContentEntity) {
        
        let trainingType: ConcreteTrainingTypeData? = if let entityTrainingType = entity.trainingType {
            
            ConcreteTrainingTypeData(id: entityTrainingType.id,
                                     name: entityTrainingType.name)
        }
        else {
            
            nil
        }
        
        self.init(id: entity.id,
                  trainingType: trainingType,
                  goalNumberOfSets: entity.goalNumberOfSets,
                  goalSetCount: entity.goalSetCount,
                  actualNumberOfSets: entity.actualNumberOfSets,
                  actualSetCount: entity.actualSetCount,
                  isAchieved: entity.isAchieved)
    }
}
