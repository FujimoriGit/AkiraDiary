//
//  MachoFramework
//
//  DiaryConverter.swift
//
//  Created by stotic-dev on 2025/03/22
//  Copyright © Macho All rights reserved.
//

import Foundation
import MachoCore

enum DiaryConverter {
    
    static func toDiary(_ entity: DiaryData) -> Diary {
        
        return .init(id: entity.id,
                     createdAt: entity.date,
                     title: entity.title,
                     mainText: entity.mainText,
                     goals: entity.goals.compactMap { GoalConverter.toGoal($0) },
                     tags: entity.tags.map { TagConverter.toTag($0) },
                     endTime: entity.endTime)
    }
}
