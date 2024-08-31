//
//  TrainingTypeEntity.swift
//
//  
//  Created by Daiki Fujimori on 2024/08/16
//  


import Foundation
import RealmSwift

public struct TrainingTypeEntity: BaseRealmEntity {
    
    public let id: UUID
    public let name: String
    
    public static let executor = RealmObserverExecutor<Self>()
    
    public init(id: UUID, name: String) {
        
        self.id = id
        self.name = name
    }
    
    public init(realmObject: TrainingTypeRealmObject) {
        
        id = realmObject.id
        name = realmObject.name
    }
    
    public func toRealmObject() -> TrainingTypeRealmObject {
        
        return TrainingTypeRealmObject(id: id, name: name)
    }
}

public class TrainingTypeRealmObject: Object {
    
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var name: String
    
    convenience init(id: UUID, name: String) {
        
        self.init()
        
        self.id = id
        self.name = name
    }
}
