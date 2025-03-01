//
//  TestRealmGenerator.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/12/02.
//

import Foundation
import MachoCore
import RealmHelper

struct TestRealmGenerator {
    
    static func setupRealm() -> Task<RealmWrapper, Error> {
        
        let config = DbConfiguration(isOnMemoryId: UUID().uuidString, version: 1)
        return RealmFactory.create(config: config)
    }
}
