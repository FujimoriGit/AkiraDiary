//
//  MachoFramework
//
//  TagCreationUtil.swift
//
//  Created by stotic-dev on 2025/03/22
//  Copyright © Macho All rights reserved.
//

import Foundation
@testable import MachoView

extension Tag {
    
    static let fine: Self = .init(id: TrainingTagData.fine.id,
                                  tagName: TrainingTagData.fine.tagName)
    static let unfine: Self = .init(id: TrainingTagData.unfine.id,
                                    tagName: TrainingTagData.unfine.tagName)
}
