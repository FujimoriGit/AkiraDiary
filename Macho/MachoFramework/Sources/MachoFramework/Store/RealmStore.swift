//
//  RealmStore.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

import Foundation
import MachoCore
import RealmHelper

final class RealmStore {
    
    static let shared = RealmStore()
    
    let realm: Task<RealmAccessible, Error>
    
    init() {
        
        let dir = URL.applicationSupportDirectory
        if !FileManager.default.fileExists(atPath: dir.path()) {
            
            do {
                
                try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            }
            catch {
                
                logger.error("Failed create directory: \(dir)")
            }
        }
        
        let config = DbConfiguration(url: dir.appending(path: "db.realm"),
                                     version: 1)
        realm = RealmFactory.create(config: config)
    }
}
