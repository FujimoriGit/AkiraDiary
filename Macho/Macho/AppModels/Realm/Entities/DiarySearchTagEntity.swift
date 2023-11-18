//
//  DiarySearchTagEntity.swift
//  Macho
//
//  Created by 佐藤汰一 on 2023/11/04.
//

import Foundation
import RealmSwift

struct DiarySearchTagEntity: BaseRealmEntity {
    
    let id: UUID
    let tagName: String
    
    static let executor = RealmObserverExecutor<Self>()
    
    init(id: UUID, tagName: String) {
        
        self.id = id
        self.tagName = tagName
    }
    
    init(realmObject: DiarySearchTagRealmObject) {
        
        id = realmObject.id
        tagName = realmObject.tagName
    }
    
    func toRealmObject() -> DiarySearchTagRealmObject {
        
        return DiarySearchTagRealmObject(id: id, tagName: tagName)
    }
}

class DiarySearchTagRealmObject: Object {
    
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var tagName: String
    
    convenience init(id: UUID, tagName: String) {
        
        self.init()
        
        self.id = id
        self.tagName = tagName
    }
}
