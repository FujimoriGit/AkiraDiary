//
//  MachoFramework
//
//  DiaryTestUtil.swift
//
//  Created by stotic-dev on 2025/03/22
//  Copyright © Macho All rights reserved.
//

@testable import MachoView

extension Diary {
    
    var isAchieved: Bool? {
        
        if case .finished(let info) = status {
            
            return info.isAchieved
        }
        
        return nil
    }
}
