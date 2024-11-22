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
        let fileUrl = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        
        logger.debug("Realm configuration(schemaVersion=\(schemeVersion.value), fileUrl=\(fileUrl?.path ?? ""))")
        
        return Realm.Configuration(
            fileURL: fileUrl,
            schemaVersion: schemeVersion.value
        )
    }
}
