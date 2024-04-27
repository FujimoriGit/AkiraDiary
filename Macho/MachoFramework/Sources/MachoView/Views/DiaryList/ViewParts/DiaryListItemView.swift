//
//  DiaryListItemView.swift
//  Macho
//
//  Created by 佐藤汰一 on 2024/01/07.
//

import ComposableArchitecture
import SwiftUI

struct DiaryListItemView: View {
    
    // MARK: tca store property
    
    private let store: StoreOf<DiaryListItemFeature>
    
    // MARK: initialize method
    
    init(store: StoreOf<DiaryListItemFeature>) {
        
        self.store = store
    }
    
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
    
    // MARK: view property
    
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
                    .frame(maxWidth: .infinity)
            }
            .foregroundStyle(Color(asset: CustomColor.appPrimaryTextColor))
            .background(Color(asset: CustomColor.appPrimaryBackgroundColor))
            .addSwipeAction {
                SwipeAction(tint: Color(asset: CustomColor.deleteSwipeBackgroundColor),
                            icon: Image(systemName: "trash.fill")) {
                    print("delete.")
                }
                SwipeAction(tint: Color(asset: CustomColor.editSwipeBackgroundColor),
                            icon: Image(systemName: "pencil")) {
                    print("edit.")
                }
            }
        }
    }
}

// MARK: - private method

private extension DiaryListItemView {
    
    func createEditItemButton(_ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text("edit")
        }
        .tint(Color(asset: CustomColor.editSwipeBackgroundColor))
    }
    
    func createDeleteItemButton(_ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text("delete")
        }
        .tint(Color(asset: CustomColor.deleteSwipeBackgroundColor))
    }
}

// MARK: - preview block

#Preview {
    ScrollView {
        LazyVStack(spacing: .zero) {
            DiaryListItemView(store: Store(initialState: DiaryListItemFeature.State(title: "2024/1/1", message: "Test Messag 1", date: Date(), isWin: false)) {
                DiaryListItemFeature()
            })
            DiaryListItemView(store: Store(initialState: DiaryListItemFeature.State(title: "2024/1/2", message: "Test Messag 2", date: Date(), isWin: true)) {
                DiaryListItemFeature()
            })
        }
    }
}
