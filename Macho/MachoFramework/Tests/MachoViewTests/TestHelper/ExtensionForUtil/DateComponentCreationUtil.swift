//
//  MachoFramework
//
//  DateComponentCreationUtil.swift
//
//  Created by stotic-dev on 2025/01/24
//  Copyright © Macho All rights reserved.
//

import Foundation

extension DateComponents {
    
    static func createDay(year: Int, month: Int, day: Int) -> DateComponents {
        
        var result: DateComponents = .init(year: year, month: month, day: day)
        result.isLeapMonth = false
        return result
    }
    
    static func createMonth(year: Int, month: Int) -> DateComponents {
        
        var result: DateComponents = .init(year: year, month: month)
        result.isLeapMonth = false
        return result
    }
}
