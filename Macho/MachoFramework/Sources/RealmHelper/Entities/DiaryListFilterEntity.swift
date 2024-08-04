//
//  DiaryListFilterEntity.swift
//
//
//  Created by 佐藤汰一 on 2024/08/03.
//

import RealmSwift

public struct DiaryListFilterEntity: BaseRealmEntity {
    
    // フィルターの種別
    public let filterTargetId: String
    // フィルターの項目
    public let filterItemId: String
    
    public static let executor = RealmObserverExecutor<Self>()
    
    public init(filterTargetId: String, filterItemId: String) {
        
        self.filterTargetId = filterTargetId
        self.filterItemId = filterItemId
    }
    
    public init(realmObject: DiaryListFilterRealmObject) {
        
        filterTargetId = realmObject.filterTargetId
        filterItemId = realmObject.filterItemId
    }
    
    public func toRealmObject() -> DiaryListFilterRealmObject {
        
        return DiaryListFilterRealmObject(filterTargetId: filterTargetId, filterItemId: filterItemId)
    }
}

public class DiaryListFilterRealmObject: Object {
    
    // フィルターの種別
    @Persisted var filterTargetId: String
    // フィルターの項目
    @Persisted var filterItemId: String
    
    convenience init(filterTargetId: String, filterItemId: String) {
        
        self.init()
        self.filterTargetId = filterTargetId
        self.filterItemId = filterItemId
    }
}
 
