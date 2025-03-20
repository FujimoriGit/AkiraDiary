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
    
    @Bindable private var store: StoreOf<DiaryListItemFeature>
    
    // MARK: initialize method
    
    init(store: StoreOf<DiaryListItemFeature>) {
        
        self.store = store
    }
    
    // MARK: - layout property
    
    // MARK: size property
    
    private let diaryStatusIconSize: CGFloat = 25
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
        Button(action: {
            store.send(.tappedDiaryItem)
        }, label: {
            createDiaryItemContent()
        })
        .foregroundStyle(Color(asset: CustomColor.appPrimaryTextColor))
        .background(Color(asset: CustomColor.appPrimaryBackgroundColor))
        .addSwipeAction {
            SwipeAction(tint: Color(asset: CustomColor.deleteSwipeBackgroundColor),
                        icon: Image(systemName: "trash.fill")) {
                store.send(.deleteItemSwipeAction)
            }
            SwipeAction(tint: Color(asset: CustomColor.editSwipeBackgroundColor),
                        icon: Image(systemName: "pencil")) {
                store.send(.editItemSwipeAction)
            }
        }
        .accessibilityHidden(true)
    }
}

// MARK: - private method

private extension DiaryListItemView {
    
    func createDiaryItemContent() -> some View {
        VStack {
            HStack(spacing: .zero) {
                createDiaryStatusIcon()
                Spacer()
                    .frame(width: winLoseLabelTrailingPadding)
                VStack(spacing: .zero) {
                    createTopContents(title: store.title,
                                      date: store.date.formatted(.date))
                    Spacer()
                        .frame(height: titlePaddingBottom)
                    createMessageContent(message: store.message)
                }
            }
            .padding(.top, baseTopPadding)
            .padding(.bottom, baseBottomPadding)
            .padding(.horizontal, baseHorizontalPadding)
            Divider()
                .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder
    func createDiaryStatusIcon() -> some View {
        switch store.diaryState {
        case .training:
            Image(systemName: "figure.highintensity.intervaltraining")
                .resizable()
                .scaledToFit()
                .frame(width: diaryStatusIconSize, height: diaryStatusIconSize)
        case .finished:
            createWinLoseIcon(isWin: store.isWin)
        }
    }
    
    func createWinLoseIcon(isWin: Bool) -> some View {
        AchieveIconView(isAchieved: isWin,
                        size: diaryStatusIconSize)
    }
    
    func createTopContents(title: String, date: String) -> some View {
        HStack(spacing: .zero) {
            Text(title)
                .font(.system(size: titleFontSize,
                              weight: .bold))
            Spacer()
            Text(date)
                .font(.system(size: dateFontSize))
        }
    }
    
    func createMessageContent(message: String) -> some View {
        Text(message)
            .font(.system(size: messageFontSize))
            .fixedSize(horizontal: false,
                       vertical: true)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity,
                   alignment: .leading)
    }
    
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
    let diaryData = DiaryData(id: UUID(),
                              date: Date(),
                              title: "sample", mainText: "sample main text",
                              goals: [
                                TrainingContentData(id: UUID(),
                                                    trainingType: .init(id: UUID(),
                                                                        name: "腹筋"),
                                                    goalNumberOfSets: 3,
                                                    goalSetCount: 3,
                                                    actualNumberOfSets: 3,
                                                    actualSetCount: 3)
                              ],
                              tags: [TrainingTagData(id: UUID(), tagName: "xxx")],
                              startTime: Date(),
                              endTime: Date())
    let trainingStatusData = DiaryData(id: UUID(),
                                       date: Date(),
                                       title: "sample", mainText: "sample main text",
                                       goals: [
                                        TrainingContentData(id: UUID(),
                                                            trainingType: .init(id: UUID(),
                                                                                name: "腹筋"),
                                                            goalNumberOfSets: 3,
                                                            goalSetCount: 3,
                                                            actualNumberOfSets: 3,
                                                            actualSetCount: 3)
                                       ],
                                       tags: [],
                                       startTime: Date(), endTime: nil)
    ScrollView {
        LazyVStack(spacing: .zero) {
            DiaryListItemView(store: Store(initialState: DiaryListItemFeature.State(diaryData)) {
                DiaryListItemFeature()
            })
            DiaryListItemView(store: Store(initialState: DiaryListItemFeature.State(trainingStatusData)) {
                DiaryListItemFeature()
            })
        }
    }
}
