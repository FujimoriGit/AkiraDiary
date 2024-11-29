//
//  DiaryListFilterConcreteData.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

import Foundation
import MachoCore

struct DiaryListFilterConcreteData: DiaryListFilterData {
    
    let id: String
    let filterTarget: String
    let filterId: UUID
    let filterValue: String
    
    init(_ item: DiaryListFilterItem) {
        
        id = item.id
        filterTarget = item.target.title
        filterId = item.filterItemId
        filterValue = item.value
    }
}
