//
//  ContentView.swift
//  Macho
//
//  Created by 藤森大輝 on 2023/10/21.
//

import ComposableArchitecture
import SwiftUI

struct ContentView: View {
    var body: some View {
        DiaryListView(store: Store(initialState: { DiaryListFeature.State() }()) {
            DiaryListFeature()
        })
    }
}

#Preview {
    ContentView()
}
