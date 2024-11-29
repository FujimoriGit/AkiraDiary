//
//  TrainingTypeEntityRepositoryImpl.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

import MachoCore
import RealmHelper

public struct TrainingTypeEntityRepositoryImpl: RealmUseable {
    
    let realm: Task<RealmAccessible, any Error>
    
    public init(_ realm: Task<RealmAccessible, any Error>) {
        
        self.realm = realm
    }
    
    public func fetchAll() async -> [TrainingTypeEntity] {
        
        return await (getRealm()?.read(where: nil) ?? [])
    }
}
