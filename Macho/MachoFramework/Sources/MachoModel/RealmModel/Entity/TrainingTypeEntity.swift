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

public struct TrainingTypeEntity: BaseRealmEntity, TrainingTypeData {
    
    public let id: UUID
    public let name: String
    
    public init(id: UUID, name: String) {
        
        self.id = id
        self.name = name
    }
    
    public init(realmObject: TrainingTypeRealmObject) {
        
        id = realmObject.id
        name = realmObject.name
    }
    
    init(_ data: some TrainingTypeData) {
        
        id = data.id
        name = data.name
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
