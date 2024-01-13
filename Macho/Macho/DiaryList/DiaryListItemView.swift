//
//  DiaryListItemView.swift
//  Macho
//
//  Created by 佐藤汰一 on 2024/01/07.
//

import ComposableArchitecture
import SwiftUI

struct DiaryListItemView: View {
    
    let store: StoreOf<DiaryListItemFeature>
    
    // MARK: layout property
    private let winLoseLabelFontSize: Font = .system(size: 25, weight: .heavy)
    
    var body: some View {
        GeometryReader { geometry in
            WithViewStore(store, observe: { $0 }) { viewStore in
                HStack(alignment: .center) {
                    Text(viewStore.isWin ? "Win" : "Lose")
                        .font(winLoseLabelFontSize)
                        .foregroundStyle(viewStore.isWin ? Color.green : Color.red)
                    VStack {
                        HStack {
                            Text(viewStore.title)
                            Spacer()
                            Text(viewStore.date.formatted(date: .abbreviated, time: .omitted))
                        }
                        Text(viewStore.message)
                            .multilineTextAlignment(.leading)
                    }
                }
            }
        }
    }
}

#Preview {
    DiaryListItemView(store: Store(initialState: DiaryListItemFeature.State(title: "2024/1/1", message: "Test Message", date: Date(), isWin: true)) {
        DiaryListItemFeature()
    })
}
