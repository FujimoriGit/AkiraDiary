//
//  RealmUseable.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

import RealmHelper

protocol RealmUseable {
    
    var realm: Task<RealmWrapper, Error> { get }
    
    func getRealm() async -> RealmWrapper?
}

extension RealmUseable {
    
    func getRealm() async -> RealmWrapper? {
        
        do {
            
            return try await realm.value
        }
        catch {
            
            logger.error("Failed create realm: \(error)")
            return nil
        }
    }
}
