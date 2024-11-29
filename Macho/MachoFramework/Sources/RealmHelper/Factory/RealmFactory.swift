//
//  RealmFactory.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/28.
//

import Foundation

public struct RealmFactory {
    
    public static func create(url: URL, version: UInt64) -> Task<RealmAccessible, Error> {
        
        return Task { RealmAccessor() }
    }
}
