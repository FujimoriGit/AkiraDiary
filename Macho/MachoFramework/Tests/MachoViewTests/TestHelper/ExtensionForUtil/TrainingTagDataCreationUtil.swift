//
//  MachoFramework
//
//  TrainingTagDataCreationUtil.swift
//
//  Created by stotic-dev on 2025/02/02
//  Copyright © Macho All rights reserved.
//

import Foundation
@testable import MachoCore
@testable import MachoView

extension TrainingTagData {
    
    static let fine: Self = .init(id: UUID(), tagName: "元気")
    static let unfine: Self = .init(id: UUID(), tagName: "不調")
    
    init(_ tag: Tag) {
        
        self.init(id: tag.id, tagName: tag.tagName)
    }
}
