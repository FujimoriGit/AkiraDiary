//
//  MachoFramework
//
//  CreatingDiary.swift
//
//  Created by stotic-dev on 2025/03/16
//  Copyright © Macho All rights reserved.
//

struct CreatingDiary {
    
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
}
