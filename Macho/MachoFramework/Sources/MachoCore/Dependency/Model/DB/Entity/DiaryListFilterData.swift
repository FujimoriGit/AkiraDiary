//
//  DiaryListFilterData.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/28.
//

import Foundation

public protocol DiaryListFilterData: Equatable, Sendable, Identifiable {
    
    var id: String { get }
    // フィルターの種別
    var filterTarget: String { get }
    // フィルターのID
    var filterId: UUID { get }
    // フィルターの項目
    var filterValue: String { get }
}
