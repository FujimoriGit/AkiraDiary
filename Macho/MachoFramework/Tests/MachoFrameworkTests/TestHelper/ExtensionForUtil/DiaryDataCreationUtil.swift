//
//  MachoFramework
//
//  DiaryDataCreationUtil.swift
//
//  Created by stotic-dev on 2025/01/24
//  Copyright © Macho All rights reserved.
//

import Foundation
@testable import MachoView

extension DiaryData {
    
    static func create(id: UUID = UUID(),
                       date: Date = .now,
                       goals: [TrainingContentData] = [],
                       tags: [TrainingTagData] = [],
                       startTime: Date? = nil,
                       endTime: Date? = nil) -> Self {
        
        return .init(id: id,
                     date: date,
                     title: "dummy \(date.formatted())",
                     mainText: "",
                     goals: goals,
                     tags: tags,
                     startTime: startTime,
                     endTime: endTime
        )
    }
}
