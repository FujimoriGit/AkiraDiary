//
//  MachoFramework
//
//  Tag.swift
//
//  Created by stotic-dev on 2025/03/09
//  Copyright © Macho All rights reserved.
//

import Foundation

struct Tag: Equatable, Identifiable {
    
    let id: UUID
    let tagName: String
}

struct SelectionTag: Equatable, Identifiable {
    
    var id: UUID {
        return tag.id
    }
    let tag: Tag
    let isSelected: Bool
}

extension SelectionTag {
    
    init(id: UUID, tagName: String, isSelected: Bool = false) {
        
        tag = Tag(id: id, tagName: tagName)
        self.isSelected = isSelected
    }
}
