//
//  RealmFactory.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/28.
//

import MachoCore
import RealmSwift

public struct RealmFactory {
    
    public static func create(config: DbConfiguration) -> Task<RealmWrapper, Error> {
        
        return Task {
            let configuration = if let fileUrl = config.url {
                
                Realm.Configuration(fileURL: fileUrl,
                                    schemaVersion: config.version)
            }
            else {
                
                Realm.Configuration(inMemoryIdentifier: config.isOnMemoryId,
                                    schemaVersion: config.version)
            }
            let realm = try await Realm(configuration: configuration, actor: RealmActor.shared)
            return await RealmWrapper(realm)
        }
    }
}
