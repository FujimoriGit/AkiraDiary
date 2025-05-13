//
//  MachoFramework
//
//  TagConverter.swift
//
//  Created by stotic-dev on 2025/03/16
//  Copyright © Macho All rights reserved.
//

import MachoCore

enum TagConverter {
    
    static func toTag(_ entity: TrainingTagData) -> Tag {
        
        return .init(id: entity.id, tagName: entity.tagName)
    }
    
    static func toEntity(_ tag: Tag) -> TrainingTagData {
        
        return .init(id: tag.id, tagName: tag.tagName)
    }
}
