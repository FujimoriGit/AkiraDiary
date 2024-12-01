//
//  RealmFactory.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/28.
//

import MachoCore

public struct RealmFactory {
    
    public static func create(config: DbConfiguration) -> Task<RealmAccessible, Error> {
        
        return Task { try await RealmAccessor(config) }
    }
}
