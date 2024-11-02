//
//  DiaryListFilterEntity.swift
//
//
//  Created by 佐藤汰一 on 2024/08/03.
//

import Foundation
import RealmSwift

public struct DiaryListFilterEntity: BaseRealmEntity {
    
    public let id: String
    // フィルターの種別
    public let filterTarget: String
    // フィルターのID
    public let filterId: UUID
    // フィルターの項目
    public let filterValue: String
    
    public static let executor = RealmObserverExecutor<Self>()
    
    public init(id: String, filterTarget: String, filterId: UUID, filterValue: String) {
        
        self.id = id
        self.filterTarget = filterTarget
        self.filterId = filterId
        self.filterValue = filterValue
    }
    
    public init(realmObject: DiaryListFilterRealmObject) {
        
        id = realmObject.id
        filterTarget = realmObject.filterTarget
        filterId = realmObject.filterId
        filterValue = realmObject.filterValue
    }
    
    public func toRealmObject() -> DiaryListFilterRealmObject {
        
        return DiaryListFilterRealmObject(id: id,
                                          filterTarget: filterTarget,
                                          filterId: filterId,
                                          filterValue: filterValue)
    }
}

public class DiaryListFilterRealmObject: Object {
    
    @Persisted(primaryKey: true) var id: String
    // フィルターの種別
    @Persisted var filterTarget: String
    // フィルターのID
    @Persisted var filterId: UUID
    // フィルターの項目
    @Persisted var filterValue: String
    
    convenience init(id: String, filterTarget: String, filterId: UUID, filterValue: String) {
        
        self.init()
        self.id = id
        self.filterTarget = filterTarget
        self.filterId = filterId
        self.filterValue = filterValue
    }
}
 
