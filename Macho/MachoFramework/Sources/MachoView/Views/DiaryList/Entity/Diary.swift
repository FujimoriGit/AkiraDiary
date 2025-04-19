//
//  MachoFramework
//
//  Diary.swift
//
//  Created by stotic-dev on 2025/04/19
//  Copyright © Macho All rights reserved.
//

import Foundation

struct Diary: Equatable {
    
    let id: UUID
    let createdAt: Date
    let title: String
    let mainText: String
    let goals: [Goal]
    let tags: [Tag]
    let status: DiaryStatus
}

extension Diary {
    
    init(id: UUID,
         createdAt: Date,
         title: String,
         mainText: String,
         goals: [Goal],
         tags: [Tag],
         endTime: Date?) {
        
        self.id = id
        self.createdAt = createdAt
        self.title = title
        self.mainText = mainText
        self.goals = goals
        self.tags = tags
        if let endTime {
            
            let info = DiaryFinishInfo(isAchieved: Self.isAchievedAllGoals(goals),
                                       endTime: endTime)
            status = .finished(info)
        }
        else {
            
            status = .training
        }
    }
    
    private static func isAchievedAllGoals(_ goals: [Goal]) -> Bool {
        
        return !goals.contains { !$0.isAchieved }
    }
}
