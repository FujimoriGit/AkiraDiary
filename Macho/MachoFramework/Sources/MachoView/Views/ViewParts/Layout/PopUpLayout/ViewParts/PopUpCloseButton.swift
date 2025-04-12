//
//  MachoFramework
//
//  PopUpCloseButton.swift
//
//  Created by stotic-dev on 2025/01/31
//  Copyright © Macho All rights reserved.
//

import SwiftUI

struct PopUpCloseButton: View {
    
    // MARK: - properties
    
    let buttonHandler: () -> Void
    
    private let iconSize: CGFloat = 25
    private let iconPadding: CGFloat = 8
    
    // MARK: - view definition
    
    var body: some View {
        Button {
            buttonHandler()
        } label: {
            Image(systemName: "xmark.circle")
                .resizable()
                .frame(width: iconSize, height: iconSize)
                .padding(iconPadding)
        }
        .frameButtonStyle(frameWidth: .zero)
        .accessibilityLabel("ポップアップ閉じるボタン")
    }
}
