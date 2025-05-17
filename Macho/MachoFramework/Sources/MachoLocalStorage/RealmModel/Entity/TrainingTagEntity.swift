//
//  TrainingTagEntity.swift
//  Macho
//
//  Created by 佐藤汰一 on 2023/11/04.
//

import Foundation
import MachoCore
import RealmHelper
import RealmSwift

extension TrainingTagData: BaseRealmEntity {
    
    public init(realmObject: TrainingTagRealmObject) {
        
        self.init(id: realmObject.id,
                  tagName: realmObject.tagName)
    }
    
    public func toRealmObject() -> TrainingTagRealmObject {
        
        return TrainingTagRealmObject(id: id, tagName: tagName)
    }
}

public class TrainingTagRealmObject: Object {
    
    @Persisted(primaryKey: true)
    var id: UUID
    @Persisted var tagName: String
    
    convenience init(id: UUID, tagName: String) {
        
        self.init()
        
        self.id = id
        self.tagName = tagName
    }
}
