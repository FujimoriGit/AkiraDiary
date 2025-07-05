//
//  MachoFramework
//
//  DiaryStatusIconView.swift
//
//  Created by stotic-dev on 2025/03/20
//  Copyright © Macho All rights reserved.
//

import SwiftUI

struct DiaryStatusIconView: View {
    
    // MARK: - private property
    
    private let status: DiaryStatus
    private let size: CGFloat
    
    // MARK: - initialize method
    
    ///  日記の状態のアイコンを生成する
    /// - Parameters:
    ///   - status: 日記の達成状態
    ///   - size: アイコンのサイズ
    init(status: DiaryStatus, size: CGFloat) {
        
        self.status = status
        self.size = size
    }
    
    // MARK: - view body
    
    var body: some View {
        switch status {
        case .training:
            Image(systemName: "figure.highintensity.intervaltraining")
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .accessibilityHidden(true)
        case .finished(let info):
            AchieveIconView(isAchieved: info.isAchieved, size: size)
        }
    }
}

#Preview("finished") {
    DiaryStatusIconView(status: .finished(.init(isAchieved: true, endTime: .now)), size: 30)
}

#Preview("training") {
    DiaryStatusIconView(status: .training, size: 30)
}
