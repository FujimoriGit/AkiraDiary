//
//  RealmFactory.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/16.
//

import Foundation
import RealmSwift

struct RealmFactory {
    
    @RealmActor
    static func make() -> Task<Realm, Never> {
        
        return Task {
            
            do {
                
                return try await Realm(configuration: getConfiguration(),
                                       actor: RealmActor.shared)
            }
            catch {
                
                fatalError("Failed create DB: \(error).")
            }
        }
    }
}

private extension RealmFactory {
    
    static func getConfiguration() -> Realm.Configuration {
        
        let schemeVersion = RealmSchemaVersion(value: 1)
        
        let dir = URL.applicationSupportDirectory
        if !FileManager.default.fileExists(atPath: dir.path()) {
            
            do {
                
                try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            }
            catch {
                
                logger.error("Failed create directory: \(dir)")
            }
        }
        
        let fileUrl = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appending(path: "db.realm")
        
        logger.debug("Realm configuration(schemaVersion=\(schemeVersion.value), fileUrl=\(fileUrl?.path ?? ""))")
        
        return Realm.Configuration(
            fileURL: fileUrl,
            schemaVersion: schemeVersion.value
        )
    }
}
