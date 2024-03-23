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
    
    // MARK: - layout property
    
    // MARK: size property
    
    private let winLoseLabelFontSize: CGFloat = 25
    private let titleFontSize: CGFloat = 20
    private let messageFontSize: CGFloat = 14
    private let dateFontSize: CGFloat = 10
    
    // MARK: padding property
    
    private let baseTopPadding: CGFloat = 16
    private let baseBottomPadding: CGFloat = 30
    private let baseHorizontalPadding: CGFloat = 15
    private let titlePaddingBottom: CGFloat = 10
    private let winLoseLabelTrailingPadding: CGFloat = 16
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                HStack(spacing: .zero) {
                    Text(viewStore.isWin ? "Win" : "Lose")
                        .font(.system(size: winLoseLabelFontSize,
                                      weight: .heavy))
                        .foregroundStyle(viewStore.isWin ? Color.green : Color.red)
                    Spacer()
                        .frame(width: winLoseLabelTrailingPadding)
                    VStack(spacing: .zero) {
                        HStack(spacing: .zero) {
                            Text(viewStore.title)
                                .font(.system(size: titleFontSize,
                                              weight: .bold))
                            Spacer()
                            Text(viewStore.date.toString(.init(date: .jp),
                                                         isOmissionTens: true))
                                .font(.system(size: dateFontSize))
                        }
                        Spacer()
                            .frame(height: titlePaddingBottom)
                        Text(viewStore.message)
                            .font(.system(size: messageFontSize))
                            .fixedSize(horizontal: false,
                                       vertical: true)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity,
                                   alignment: .leading)
                        Spacer()
                    }
                }
                .padding(.top, baseTopPadding)
                .padding(.bottom, baseBottomPadding)
                .padding(.horizontal, baseHorizontalPadding)
                Divider()
            }
        }
    }
}

#Preview {
    DiaryListItemView(store: Store(initialState: DiaryListItemFeature.State(title: "2024/1/1", message: "Test Messag", date: Date(), isWin: true)) {
        DiaryListItemFeature()
    })
}
