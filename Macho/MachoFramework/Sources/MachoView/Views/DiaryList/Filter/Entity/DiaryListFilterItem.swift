//
//  DiaryListFilterItem.swift
//  
//
//  Created by 佐藤汰一 on 2024/08/04.
//

import Foundation

struct DiaryListFilterItem: Identifiable, Equatable {
    
    /// ID
    let id: UUID
    /// フィルター種別
    let target: DiaryListFilterTarget
    /// フィルター種別内の値
    let value: String
}
