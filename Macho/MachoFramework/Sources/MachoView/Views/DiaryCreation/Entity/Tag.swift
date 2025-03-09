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
    
    var id: UUID { entity.id }
    let entity: TrainingTagData
    var isSelected = false
}
