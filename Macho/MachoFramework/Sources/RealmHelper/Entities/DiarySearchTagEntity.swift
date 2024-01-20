//
//  DiarySearchTagEntity.swift
//  Macho
//
//  Created by 佐藤汰一 on 2023/11/04.
//

import Foundation
import RealmSwift

public struct DiarySearchTagEntity: BaseRealmEntity {
    
    public let id: UUID
    public let tagName: String
    
    public static let executor = RealmObserverExecutor<Self>()
    
    public init(id: UUID, tagName: String) {
        
        self.id = id
        self.tagName = tagName
    }
    
    public init(realmObject: DiarySearchTagRealmObject) {
        
        id = realmObject.id
        tagName = realmObject.tagName
    }
    
    public func toRealmObject() -> DiarySearchTagRealmObject {
        
        return DiarySearchTagRealmObject(id: id, tagName: tagName)
    }
}

public class DiarySearchTagRealmObject: Object {
    
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var tagName: String
    
    convenience init(id: UUID, tagName: String) {
        
        self.init()
        
        self.id = id
        self.tagName = tagName
    }
}
