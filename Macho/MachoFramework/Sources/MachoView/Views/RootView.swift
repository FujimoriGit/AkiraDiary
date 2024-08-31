//
//  RootView.swift
//
//
//  Created by 佐藤汰一 on 2024/02/04.
//

import SwiftUI

public struct RootView: View {
    
    public init() {
        // nop
    }
    
    public var body: some View {
        ZStack {
            VStack {
                Text("Hello, World!")
                    .foregroundStyle(Color(asset: CustomColor.appPrimaryTextColor))
                Button {
                    logger.debug("tapped fill button")
                } label: {
                    HStack {
                        Spacer()
                        Text("fill button")
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                .fillButtonStyle(backgroundColor: .accentColor)
                Button {
                    logger.info("tapped frame button")
                } label: {
                    HStack {
                        Spacer()
                        Text("fill button")
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                .frameButtonStyle(foregroundColor: .red,
                                  backgroundColor: .purple,
                                  cornerRadius: 20)
            }
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    RootView()
}
