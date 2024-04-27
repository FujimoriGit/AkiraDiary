//
//  IndicatorView.swift
//  Macho
//
//  Created by 佐藤汰一 on 2024/03/24.
//

import SwiftUI

enum IndicatorStyle {
    
    /// GrayのIndicator(Apple標準のIndicator)
    case shortGray

    /// IndicatorのViewを返す
    fileprivate var indicator: some View {
        
        switch self {
            
        case .shortGray:
            return ProgressView()
        }
    }
}

struct IndicatorView: View {
    
    private var isShowing: Bool
    private let style: IndicatorStyle
    
    init(isShowing: Bool, style: IndicatorStyle = .shortGray) {
        
        self.isShowing = isShowing
        self.style = style
    }
    
    var body: some View {
        if isShowing {
            style.indicator
        }
    }
}
