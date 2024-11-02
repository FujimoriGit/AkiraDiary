//
//  NavigationBackButton.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/10/26.
//

import SwiftUI

struct NavigationBackButton: View {
    
    // MARK: - private property
    
    // MARK: constant
    
    private let padding: CGFloat = 6
    private let size = CGSize(width: 25, height: 25)
    
    // MARK: parameter
    
    private let action: () -> Void
    
    // MARK: - initialize method
    
    init(action: @escaping () -> Void) {
        
        self.action = action
    }
    
    // MARK: - view body
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "chevron.backward")
                .resizable()
                .padding(padding)
                .frame(width: size.width,
                       height: size.height)
                .accessibilityHidden(true)
        }
        .frameButtonStyle(frameWidth: .zero)
    }
}

#Preview {
    NavigationBackButton {
        print("Tapped pop button.")
    }
}
