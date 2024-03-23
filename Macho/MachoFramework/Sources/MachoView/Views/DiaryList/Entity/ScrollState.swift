//
//  ScrollState.swift
//  Macho
//
//  Created by 佐藤汰一 on 2024/03/02.
//

import Foundation

struct ScrollState: Equatable, Sendable {
    
    /// 現在のY軸の値(0>となればスクロール中)
    var offsetY: CGFloat
    /// スクロール中かどうか
    var isScrolling: Bool {
        
        return offsetY < 0
    }
    
    init(offsetY: CGFloat) {
        
        self.offsetY = offsetY
    }
    
    init() {
        
        self.offsetY = .zero
    }
}
