//
//  ConcreteDiaryListFilterData+Extension.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

import Foundation
@testable import MachoCore
@testable import MachoView

extension ConcreteDiaryListFilterData {
    
    init(target: DiaryListFilterTarget, filterItemId: UUID, value: String) {
        
        self.init(id: filterItemId.uuidString + String(target.num),
                  filterTarget: target.rawValue,
                  filterId: filterItemId,
                  filterValue: value)
    }
}
