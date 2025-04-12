//
//  MachoFramework
//
//  CreatingDiary.swift
//
//  Created by stotic-dev on 2025/03/16
//  Copyright © Macho All rights reserved.
//

import Foundation

struct CreatingDiary: Equatable {
    
    let id: UUID?
    let createdAt: Date?
    let title: String?
    let mainText: String?
    let goals: [Goal]
    let tags: [Tag]
    
    var canSave: Bool {
        
        if title?.isEmpty ?? true { return false }
        if mainText?.isEmpty ?? true { return false }
        if goals.isEmpty { return false }
        
        return true
    }
    
    var isEditMode: Bool {
        
        return id != nil && createdAt != nil && canSave
    }
    
    func edit(title: String? = nil,
              mainText: String? = nil,
              goals: [Goal]? = nil,
              tags: [Tag]? = nil) -> Self {
        
        return .init(id: self.id,
                     createdAt: self.createdAt,
                     title: title ?? self.title,
                     mainText: mainText ?? self.mainText,
                     goals: goals ?? self.goals,
                     tags: tags ?? self.tags)
    }
}

extension CreatingDiary {
    
    static let initial: Self = .init(id: nil,
                                     createdAt: nil,
                                     title: nil,
                                     mainText: nil,
                                     goals: [],
                                     tags: [])
}
