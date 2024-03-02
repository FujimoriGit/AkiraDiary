//
//  ContentView.swift
//  Macho
//
//  Created by 藤森大輝 on 2023/10/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Button {
                print("tapped button")
            } label: {
                HStack(spacing: .zero) {
                    Spacer()
                    Text("Frame Button")
                    Spacer()
                }
                .padding(.vertical, 8)
            }
            .frameButtonStyle(backgroundColor: .blue, cornerRadius: 20)
            Button {
                print("tapped button")
            } label: {
                HStack(spacing: .zero) {
                    Spacer()
                    Text("Fill Button")
                    Spacer()
                }
                .padding(.vertical, 8)
            }
            .fillButtonStyle()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
