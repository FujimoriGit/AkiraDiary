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
    
    // size property
    private let winLoseLabelFontSize: Font = .system(size: 25, weight: .heavy)
    private let titleFontSize: CGFloat = 20
    private let messageFontSize: CGFloat = 14
    private let dateFontSize: CGFloat = 10
    
    // padding property
    private let baseVerticalPadding: CGFloat = 30
    private let baseHorizontalPadding: CGFloat = 15
    private let titlePaddingBottom: CGFloat = 10
    
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                HStack(alignment: .center) {
                    Text(viewStore.isWin ? "Win" : "Lose")
                        .font(winLoseLabelFontSize)
                        .foregroundStyle(viewStore.isWin ? Color.green : Color.red)
                    VStack(spacing: .zero) {
                        HStack(spacing: .zero) {
                            Text(viewStore.title)
                                .font(.system(size: titleFontSize))
                            Spacer()
                            Text(viewStore.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.system(size: dateFontSize))
                        }
                        Spacer()
                            .frame(height: titlePaddingBottom)
                        Text(viewStore.message)
                            .font(.system(size: messageFontSize))
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding(.vertical, baseVerticalPadding)
                .padding(.horizontal, baseHorizontalPadding)
                
                Divider()
            }
        }
    }
}

#Preview {
    DiaryListItemView(store: Store(initialState: DiaryListItemFeature.State(title: "2024/1/1", message: "Test Messag xxxxxxxxdjlsjfksdjflsjfjlsjflajdkfjdjksjfkjsdfjalfkdsjflsdjfasjkjflsd", date: Date(), isWin: true)) {
        DiaryListItemFeature()
    })
}
