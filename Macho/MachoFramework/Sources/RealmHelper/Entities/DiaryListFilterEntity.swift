//
//  DiaryListFilterEntity.swift
//
//
//  Created by 佐藤汰一 on 2024/08/03.
//

import Foundation
import RealmSwift

public struct DiaryListFilterEntity: BaseRealmEntity {
    
    public let id: UUID
    // フィルターの種別
    public let filterTarget: String
    // フィルターの項目
    public let filterValue: String
    
    public static let executor = RealmObserverExecutor<Self>()
    
    public init(id: UUID, filterTarget: String, filterValue: String) {
        
        self.id = id
        self.filterTarget = filterTarget
        self.filterValue = filterValue
    }
    
    public init(realmObject: DiaryListFilterRealmObject) {
        
        id = realmObject.id
        filterTarget = realmObject.filterTarget
        filterValue = realmObject.filterValue
    }
    
    public func toRealmObject() -> DiaryListFilterRealmObject {
        
        return DiaryListFilterRealmObject(id: id, filterTarget: filterTarget, filterValue: filterValue)
    }
}

public class DiaryListFilterRealmObject: Object {
    
    @Persisted(primaryKey: true) var id: UUID
    // フィルターの種別
    @Persisted var filterTarget: String
    // フィルターの項目
    @Persisted var filterValue: String
    
    convenience init(id: UUID, filterTarget: String, filterValue: String) {
        
        self.init()
        self.filterTarget = filterTarget
        self.filterValue = filterValue
    }
}
 
