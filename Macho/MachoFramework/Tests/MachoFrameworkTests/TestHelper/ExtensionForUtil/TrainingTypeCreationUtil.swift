//
//  MachoFramework
//
//  TrainingTypeCreationUtil.swift
//
//  Created by stotic-dev on 2025/01/24
//  Copyright © Macho All rights reserved.
//

import Foundation
@testable import MachoView

extension TrainingTypeData {
    
    /// 腹筋
    static let abs = TrainingTypeData(id: UUID(), name: "腹筋")
    /// ベンチプレス
    static let benchPress = TrainingTypeData(id: UUID(), name: "ベンチプレス")
}

extension TrainingType {
    
    /// 腹筋
    static let abs = TrainingType(id: TrainingTypeData.abs.id,
                                  name: TrainingTypeData.abs.name)
    /// ベンチプレス
    static let benchPress = TrainingType(id: TrainingTypeData.benchPress.id,
                                         name: TrainingTypeData.benchPress.name)
}
