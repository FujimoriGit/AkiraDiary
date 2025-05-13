//
//  MachoFramework
//
//  DateComponents+Extension.swift
//
//  Created by stotic-dev on 2025/01/23
//  Copyright © Macho All rights reserved.
//

import Foundation

extension DateComponents {
    
    /// 同じ日付かどうかを比較する
    func isMatchDate(_ comparisonTarget: DateComponents) -> Bool {
        
        return year == comparisonTarget.year &&
        month == comparisonTarget.month &&
        day == comparisonTarget.day
    }
}
