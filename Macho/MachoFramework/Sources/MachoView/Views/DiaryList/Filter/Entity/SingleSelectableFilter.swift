//
//  SingleSelectableFilter.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/09/21.
//

import Foundation

protocol SingleSelectableFilter {
    
    /// 単一項目のフィルターのID
    var targetId: UUID { get }
}
