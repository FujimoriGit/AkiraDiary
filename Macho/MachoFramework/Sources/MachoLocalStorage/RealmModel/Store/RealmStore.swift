//
//  RealmStore.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

import Foundation
import MachoCore
import RealmHelper

final class RealmStore: Sendable {
    
    static let shared = RealmStore()
    
    private let realm: Task<RealmWrapper, Error>
    
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
        logger.info("Created realm instance: \(config)")
    }
    
    func getRealm() -> Task<RealmWrapper, Never> {
        
        return Task {
            do {
                
                return try await realm.value
            }
            catch {
                
                preconditionFailure("Failed create realm: \(error)")
            }
        }
    }
}
