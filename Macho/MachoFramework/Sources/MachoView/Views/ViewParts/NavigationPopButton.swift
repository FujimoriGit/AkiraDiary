//
//  NavigationPopButton.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/10/26.
//

import SwiftUI

struct NavigationPopButton: View {
    
    private let padding: CGFloat = 6
    private let size = CGSize(width: 25, height: 25)
    
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "chevron.left")
                .resizable()
                .padding()
                .frame(width: size.width, height: size.height)
                .accessibilityHidden(true)
        }
        .frameButtonStyle(frameWidth: .zero)
    }
}

#Preview {
    NavigationPopButton {
        print("Tapped pop button.")
    }
}
