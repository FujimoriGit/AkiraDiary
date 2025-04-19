//
//  MachoFramework
//
//  DiaryCreationUtil.swift
//
//  Created by stotic-dev on 2025/03/22
//  Copyright © Macho All rights reserved.
//

import Foundation
@testable import MachoView

extension Diary {
    
    private static let defaultEntTime = Date()
    
    static func create(id: UUID = UUID(),
                       date: Date = .now,
                       title: String? = nil,
                       mainText: String = "",
                       goals: [Goal] = [],
                       tags: [Tag] = [],
                       endTime: Date? = Self.defaultEntTime) -> Self {
        
        return .init(
            id: id,
            createdAt: date,
            title: title ?? "dummy \(date.formatted())",
            mainText: mainText,
            goals: goals,
            tags: tags,
            endTime: endTime
        )
    }
}
