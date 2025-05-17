//
//  TrainingTypeEntity.swift
//
//  
//  Created by Daiki Fujimori on 2024/08/16
//  

import Foundation
import MachoCore
import RealmHelper
import RealmSwift

extension TrainingTypeData: BaseRealmEntity, Identifiable {
    
    public init(realmObject: TrainingTypeRealmObject) {
        
        self.init(id: realmObject.id,
                  name: realmObject.name)
    }
    
    public func toRealmObject() -> TrainingTypeRealmObject {
        
        return TrainingTypeRealmObject(id: id, name: name)
    }
}

public class TrainingTypeRealmObject: Object {
    
    @Persisted(primaryKey: true)
    var id: UUID
    @Persisted var name: String
    
    convenience init(id: UUID, name: String) {
        
        self.init()
        
        self.id = id
        self.name = name
    }
}
