//
//  DiaryListFilterDataConverter.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

import MachoCore

struct DiaryListFilterDataConverter {
    
    static func convertToDiaryFilterItemList(_ entities: [DiaryListFilterData]) -> [DiaryListFilterItem] {
        
        return entities.compactMap {
            
            guard let target: DiaryListFilterTarget = .init(rawValue: $0.filterTarget) else { return nil }
            return DiaryListFilterItem(target: target,
                                       filterItemId: $0.filterId,
                                       value: $0.filterValue)
        }
    }
    
    static func convertToDiaryListFilterDataList(_ items: [DiaryListFilterItem]) -> [DiaryListFilterData] {
        
        return items.map { DiaryListFilterData($0) }
    }
}

extension DiaryListFilterData {
    
    init(_ item: DiaryListFilterItem) {
        
        self.init(id: item.id,
                  filterTarget: item.target.rawValue,
                  filterId: item.filterItemId,
                  filterValue: item.value)
    }
}
