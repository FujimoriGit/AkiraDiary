//
//  DiaryListFilterDataConverter.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

import MachoCore

struct DiaryListFilterDataConverter {
    
    static func convertToDiaryFilterItemList(_ entities: [any DiaryListFilterData]) -> [DiaryListFilterItem] {
        
        return entities.compactMap {
            
            guard let target: DiaryListFilterTarget = .init(rawValue: $0.filterTarget) else { return nil }
            return DiaryListFilterItem(target: target,
                                       filterItemId: $0.filterId,
                                       value: $0.filterValue)
        }
    }
    
    static func convertToDiaryListFilterDataList(_ items: [DiaryListFilterItem]) -> [some DiaryListFilterData] {
        
        return items.map { DiaryListFilterConcreteData($0) }
    }
}
