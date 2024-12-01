//
//  DbConfiguration+Extension.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/30.
//

import MachoCore

extension DbConfiguration {
    
    init(isOnMemoryId: String, version: UInt64) {
        
        self.init(url: nil,
                  version: version,
                  isOnMemoryId: isOnMemoryId)
    }
}
