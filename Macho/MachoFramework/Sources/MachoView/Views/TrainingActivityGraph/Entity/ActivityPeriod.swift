//
//  ActivityPeriod.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/24.
//

import Foundation

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
    
    /// 引数の開始日付から、`DateInterval`として期間を返す
    func getDateInterval(_ startDate: Date) -> DateInterval? {
        
        guard let endDate = Calendar.current.date(byAdding: calendarComponent, value: 1, to: startDate) else {
            
            return nil
        }
        return .init(start: startDate, end: endDate)
    }
}

private extension ActivityPeriod {
    
    var calendarComponent: Calendar.Component {
        
        switch self {
            
        case .week:
            return .weekOfMonth
            
        case .month:
            return .month
            
        case .year:
            return .year
        }
    }
}
