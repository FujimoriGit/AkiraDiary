//
//  MachoFramework
//
//  SelectionTagConverter.swift
//
//  Created by stotic-dev on 2025/03/22
//  Copyright © Macho All rights reserved.
//

import MachoCore

enum SelectionTagConverter {
    
    static func toTag(_ entity: TrainingTagData, isSelected: Bool = false) -> SelectionTag {
        
        return .init(id: entity.id, tagName: entity.tagName, isSelected: isSelected)
    }
    
    static func toEntity(_ selectionTag: SelectionTag) -> TrainingTagData {
        
        return .init(id: selectionTag.id, tagName: selectionTag.tag.tagName)
    }
}
