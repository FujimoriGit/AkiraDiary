// The Swift Programming Language
// https://docs.swift.org/swift-book

import MachoView
import SwiftUI

public struct ContentView: View {
    
    public init() {}
    
    public var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
