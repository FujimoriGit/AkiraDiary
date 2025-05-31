//
//  MachoFramework
//
//  RealmTestHelper.swift
//
//  Created by stotic-dev on 2025/02/28
//  Copyright © Macho All rights reserved.
//

import MachoCore
import RealmHelper
import XCTest

enum RealmTestHelper {
    
    static func getMockRealm() async throws -> RealmWrapper {
        
        return try await RealmFactory.create(config: .init(
            url: nil,
            version: 1,
            isOnMemoryId: UUID().uuidString
        ))
        .value
    }
}
