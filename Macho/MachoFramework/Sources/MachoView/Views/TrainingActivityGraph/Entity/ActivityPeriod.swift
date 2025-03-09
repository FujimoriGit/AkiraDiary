//
//  ActivityPeriod.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/24.
//

enum ActivityPeriod: Int, CaseIterable {
    
    case week
    case month
    case year
    
    var title: String {
        
        switch self {
            
        case .week:
            "1週間"
            
        case .month:
            "1ヶ月"
            
        case .year:
            "1年"
        }
    }
}
