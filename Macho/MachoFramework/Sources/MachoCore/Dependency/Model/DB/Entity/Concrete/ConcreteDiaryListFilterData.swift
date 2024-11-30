//
//  ConcreteDiaryListFilterData.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

import Foundation

public struct ConcreteDiaryListFilterData: DiaryListFilterData {
    
    public let id: String
    public let filterTarget: String
    public let filterId: UUID
    public let filterValue: String
    
    public init(id: String,
                filterTarget: String,
                filterId: UUID,
                filterValue: String) {
        
        self.id = id
        self.filterTarget = filterTarget
        self.filterId = filterId
        self.filterValue = filterValue
    }
}
