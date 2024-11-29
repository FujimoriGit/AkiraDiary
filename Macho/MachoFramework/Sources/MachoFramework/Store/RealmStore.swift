//
//  RealmStore.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

import Foundation
import RealmHelper

final class RealmStore {
    
    static let shared = RealmStore()
    
    let realm: Task<RealmAccessible, Error>
    
    init() {
        
        realm = RealmFactory.create(url: URL.applicationSupportDirectory
            .appending(path: "db.realm"),
                                    version: 1)
    }
}
