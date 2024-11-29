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

public struct TrainingTagEntity: BaseRealmEntity, TrainingTagData {
    
    public let id: UUID
    public let tagName: String
    
    public static let executor = RealmObserverExecutor<Self>()
    
    public init(id: UUID, tagName: String) {
        
        self.id = id
        self.tagName = tagName
    }
    
    public init(realmObject: TrainingTagRealmObject) {
        
        id = realmObject.id
        tagName = realmObject.tagName
    }
    
    init(_ data: some TrainingTagData) {
        
        id = data.id
        tagName = data.tagName
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
