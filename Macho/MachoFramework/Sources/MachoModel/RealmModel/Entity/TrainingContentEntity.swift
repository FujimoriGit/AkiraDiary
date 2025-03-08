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

extension TrainingContentData: BaseRealmEntity {
    
    public init(realmObject: TrainingContentRealmObject) {
        
        let trainingTypeEntity: TrainingTypeData? = if let trainingType = realmObject.trainingType {
            
            TrainingTypeData(realmObject: trainingType)
        }
        else {
            
            nil
        }
        
        self.init(
            id: realmObject.id,
            trainingType: trainingTypeEntity,
            goalNumberOfSets: realmObject.goalNumberOfSets,
            goalSetCount: realmObject.goalSetCount,
            actualNumberOfSets: realmObject.actualNumberOfSets,
            actualSetCount: realmObject.actualSetCount,
            isAchieved: Self.isAchieved(
                actualSetCount: realmObject.actualSetCount,
                actualNumberOfSets: realmObject.actualNumberOfSets,
                goalSetCount: realmObject.goalSetCount,
                goalNumberOfSets: realmObject.goalNumberOfSets
            )
        )
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

private extension TrainingContentData {
    
    static func isAchieved(actualSetCount: Int?,
                           actualNumberOfSets: Int?,
                           goalSetCount: Int,
                           goalNumberOfSets: Int) -> Bool {
        
        guard let actualSetCount,
              let actualNumberOfSets else { return false }
        
        if actualSetCount > goalSetCount ||
            (actualSetCount == goalSetCount && actualNumberOfSets >= goalNumberOfSets) {
            
            return true
        }
        
        return false
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
