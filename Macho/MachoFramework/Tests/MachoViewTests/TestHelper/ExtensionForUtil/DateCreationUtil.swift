//
//  MachoFramework
//
//  DateCreationUtil.swift
//
//  Created by stotic-dev on 2025/01/24
//  Copyright © Macho All rights reserved.
//

import Foundation

extension Date {
    
    static func create(year: Int, month: Int, day: Int, hour: Int = .zero, second: Int = .zero) -> Date {
        
        return Calendar.current.date(from: .init(year: year,
                                                 month: month,
                                                 day: day,
                                                 hour: hour,
                                                 second: second))!
    }
}
