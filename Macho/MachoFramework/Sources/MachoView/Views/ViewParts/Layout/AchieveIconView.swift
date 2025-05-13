//
//  AchieveIconView.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/02.
//

import SwiftUI

struct AchieveIconView: View {
    
    // MARK: - private property
    
    private let isAchieved: Bool
    private let size: CGFloat
    
    // MARK: - initialize method
    
    ///  目標達成のアイコンを生成する
    /// - Parameters:
    ///   - isAchieved: 目標を達成したかどうか
    ///   - size: アイコンのサイズ
    init(isAchieved: Bool, size: CGFloat) {
        
        self.isAchieved = isAchieved
        self.size = size
    }
    
    // MARK: - view body
    
    var body: some View {
        Text(isAchieved ? "Win" : "Lose")
            .font(.system(size: size,
                          weight: .heavy))
            .foregroundStyle(Color.getWinOrLoseColorByIsAchieved(isAchieved))
    }
}

#Preview("Win") {
    AchieveIconView(isAchieved: true, size: 30)
}

#Preview("Lose") {
    AchieveIconView(isAchieved: false, size: 30)
}
