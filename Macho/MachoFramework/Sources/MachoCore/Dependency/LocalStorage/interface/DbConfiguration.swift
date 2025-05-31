//
//  DbConfiguration.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/30.
//

import Foundation

public struct DbConfiguration: Sendable {
    
    public let url: URL?
    public let version: UInt64
    public let isOnMemoryId: String?
    
    public init(url: URL?, version: UInt64, isOnMemoryId: String? = nil) {
        
        self.url = url
        self.version = version
        self.isOnMemoryId = isOnMemoryId
    }
}
