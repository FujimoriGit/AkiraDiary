//
//  DiaryDetailView.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/10/26.
//

import ComposableArchitecture
import RealmHelper
import SwiftUI

struct DiaryDetailView: View {
    
    // MARK: private property
    
    // MARK: store
    
    @Bindable private var store: StoreOf<DiaryDetailFeature>
    
    // MARK: layout constant
    
    private let titleFontSize: CGFloat = 20
    private let messageFontSize: CGFloat = 13
    private let sectionTitleFontSize: CGFloat = 14
    private let achievedIconFontSize: CGFloat = 25
    private let trainingDetailTextFontSize: CGFloat = 14
    
    private let contentsHorizontalPadding: CGFloat = 16
    private let titleBottomPadding: CGFloat = 18
    private let dividerTopPadding: CGFloat = 30
    private let dividerBottomPadding: CGFloat = 20
    private let trainingTotalResultSectionSpace: CGFloat = 16
    
    private let dividerHeight: CGFloat = 1
    
    private let defaultMessageLineLimit = 3
    
    // MARK: - initialize method
    
    init(store: StoreOf<DiaryDetailFeature>) {
        
        self.store = store
    }
    
    // MARK: - view body
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            ZStack {
                createContentsArea()
            }
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    NavigationBackButton {
                       // TODO: 戻るイベントを呼ぶ
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        
                    }, label: {
                        Image(systemName: "pencil")
                            .resizable()
                            .padding(6)
                            .accessibilityHidden(true)
                    })
                    .frameButtonStyle(frameWidth: .zero)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Detail")
        } destination: { store in
            // TODO: 編集画面への遷移を実装する
        }
    }
}

// MARK: - private method

private extension DiaryDetailView {
    
    func createContentsArea() -> some View {
        ScrollView {
            LazyVStack(spacing: .zero) {
                Group {
                    createTitleView()
                    Spacer()
                        .frame(height: titleBottomPadding)
                    createMessageView()
                }
                .padding(.horizontal, contentsHorizontalPadding)
                createContentsDivider()
                createTagsSectionView()
                    .padding(.horizontal, contentsHorizontalPadding)
                createContentsDivider()
                createTrainingResultSectionView(store.totalResult)
                    .padding(.horizontal, contentsHorizontalPadding)
            }
        }
    }
    
    func createTitleView() -> some View {
        Text(store.title)
            .font(.system(size: titleFontSize, weight: .bold))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func createMessageView() -> some View {
        Text(store.message)
            .font(.system(size: messageFontSize))
            .lineLimit(defaultMessageLineLimit)
    }
    
    func createTagsSectionView() -> some View {
        VStack(spacing: .zero) {
            Text("Tags")
                .font(.system(size: sectionTitleFontSize,
                              weight: .bold))
                .frame(maxWidth: .infinity,
                       alignment: .leading)
        }
    }
    
    func createTrainingResultSectionView(_ trainingResult: TotalTrainingResult) -> some View {
        VStack(alignment: .leading, spacing: trainingTotalResultSectionSpace) {
            Text("Training")
                .font(.system(size: sectionTitleFontSize,
                              weight: .bold))
                .frame(maxWidth: .infinity,
                       alignment: .leading)
            AchieveIconView(isAchieved: true,
                            size: achievedIconFontSize)
            VStack(alignment: .leading, spacing: 8) {
                Text("種目数：\(trainingResult.trainingCount)")
                Text("トレーニング開始時間：\(trainingResult.startDateDisplayText)")
                Text("トレーニング終了時間：\(trainingResult.endDateDisplayText)")
                Text("総トレーニング時間：\(trainingResult.totalTrainingTimeDurationText)")
            }
            .font(.system(size: trainingDetailTextFontSize))
        }
    }
    
    func createContentsDivider() -> some View {
        VStack(spacing: .zero) {
            Spacer()
                .frame(height: dividerTopPadding)
            Rectangle()
                .ignoresSafeArea()
                .frame(maxWidth: .infinity,
                       maxHeight: dividerHeight)
            Spacer()
                .frame(height: dividerBottomPadding)
        }
    }
}

// MARK: - preview

#Preview {
    let goal1 = TrainingGoalEntity(id: UUID(),
                                   goalType: TrainingTypeEntity(id: UUID(), name: "腹筋"), numberOfSets: 3,
                                   setCount: 3,
                                   startTime: Date(),
                                   endTime: Date(),
                                   isSuccess: true)
    let tag1 = TrainingTagEntity(id: UUID(), tagName: "XXX")
    let initialDiaryEntity = DiaryEntity(id: UUID(),
                                         date: Date(),
                                         title: "Preview",
                                         mainText: "preview sample message xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
                                         goals: [goal1],
                                         tags: [tag1])
    DiaryDetailView(store: Store(initialState: DiaryDetailFeature.State(diary: initialDiaryEntity),
                                 reducer: { DiaryDetailFeature() }))
}
