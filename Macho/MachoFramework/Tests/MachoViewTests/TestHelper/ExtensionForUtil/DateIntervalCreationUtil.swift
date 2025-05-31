//
//  MachoFramework
//
//  DateIntervalCreationUtil.swift
//
//  Created by stotic-dev on 2025/01/30
//  Copyright © Macho All rights reserved.
//

import Foundation
@testable import MachoView

extension DateInterval {
    
    /// アクティビティ期間から表示期間を生成する
    static func create(from: Date, period: ActivityPeriod) -> Self {
        
        let oneDayTimeInterval: TimeInterval = 60 * 60 * 24
        
        let addingTimeInterval: TimeInterval = switch period {
            
        case .week:
            oneDayTimeInterval * 7
            
        case .month:
            Calendar.current.date(byAdding: .month, value: 1, to: from)!
                .timeIntervalSince(from)
            
        case .year:
            Calendar.current.date(byAdding: .year, value: 1, to: from)!
                .timeIntervalSince(from)
        }
        
        return .init(start: from,
                     end: from.addingTimeInterval(addingTimeInterval - oneDayTimeInterval))
    }
}
