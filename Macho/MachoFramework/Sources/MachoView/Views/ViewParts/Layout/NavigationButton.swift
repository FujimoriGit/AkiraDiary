//
//  NavigationButton.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/10/26.
//

import SwiftUI

struct NavigationButton: View {
    
    // MARK: - private property
    
    // MARK: constant
    
    private let padding: CGFloat = 6
    private let size = CGSize(width: 25, height: 25)
    
    // MARK: parameter
    
    private let type: ButtonType
    private let action: () -> Void
    
    // MARK: - initialize method
    
    init(_ type: ButtonType, action: @escaping () -> Void) {
        
        self.type = type
        self.action = action
    }
    
    // MARK: - view body
    
    var body: some View {
        Button {
            action()
        } label: {
            type.image
                .resizable()
                .padding(padding)
                .frame(width: size.width,
                       height: size.height)
                .accessibilityHidden(true)
        }
        .frameButtonStyle(frameWidth: .zero)
    }
}

// MARK: - definition exclusive enum type

extension NavigationButton {
    
    enum ButtonType {
        
        case back
        case other(icon: Image)
        
        var image: Image {
            
            switch self {
                
            case .back:
                return Image(systemName: "chevron.backward")
                
            case .other(let image):
                return image
            }
        }
    }
}

#Preview("back") {
    NavigationButton(.back) {
        print("Tapped pop button.")
    }
}

#Preview("other") {
    NavigationButton(.other(icon: Image(systemName: "pencil"))) {
        print("Tapped pop button.")
    }
}
