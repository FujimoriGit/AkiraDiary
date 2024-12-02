//
//  TestRealmGenerator.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/12/02.
//

import MachoCore
import RealmHelper

struct TestRealmGenerator {
    
    static func setupRealm(_ caseName: String) -> Task<RealmAccessible, Error> {
        
        let config = DbConfiguration(isOnMemoryId: caseName, version: 1)
        return RealmFactory.create(config: config)
    }
}
