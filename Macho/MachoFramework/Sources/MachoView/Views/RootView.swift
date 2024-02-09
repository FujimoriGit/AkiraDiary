//
//  RootView.swift
//
//
//  Created by 佐藤汰一 on 2024/02/04.
//

import SwiftUI

public struct RootView: View {
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                .foregroundStyle(Color(asset: CustomColor.appPrimaryTextColor))
        }
    }
}

#Preview {
    RootView()
}
