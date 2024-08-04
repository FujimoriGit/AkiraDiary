//
//  DiaryListFilterItem.swift
//  
//
//  Created by 佐藤汰一 on 2024/08/04.
//

struct DiaryListFilterItem: Identifiable, Equatable {
    
    var id: String {
        
        return target.title + value
    }
    
    let target: DiaryListFilterTarget
    let value: String
}
