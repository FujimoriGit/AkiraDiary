//
//  DiaryDetailView.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/10/26.
//

import ComposableArchitecture
import MachoCore
import SwiftUI

struct DiaryDetailView: View {
    
    // MARK: private property
    
    // MARK: store
    
    @Bindable private var store: StoreOf<DiaryDetailFeature>
    
    // MARK: layout constant
    
    private let achievedIconFontSize: CGFloat = 25
    private let dividerHeight: CGFloat = 1
    private let tagCornerRadius: CGFloat = 10
    private let trainingItemDividerOpacity = 0.3
    private let defaultMessageLineLimit = 3
    private let resultDescriptionTextFormat = ":%dセット%d回"
    
    // MARK: - initialize method
    
    init(store: StoreOf<DiaryDetailFeature>) {
        
        self.store = store
    }
    
    // MARK: - view body
    
    var body: some View {
        ZStack {
            createContentsArea()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationButton(.back) {
                    store.send(.tappedBackNavigationButton)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                // swiftlint:disable:next accessibility_label_for_image
                NavigationButton(.other(icon: Image(systemName: "pencil"))) {
                    store.send(.tappedEditButton)
                }
            }
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Detail")
        .navigationDestination(
            item: $store.scope(
                state: \.navigationDestination?.editDiary,
                action: \.navigationDestination.editDiary
            )
        ) {
            DiaryCreationView(store: $0)
        }
        .onAppear {
            store.send(.onAppear)
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
                        .frame(height: .space(.medium))
                    createMessageView()
                }
                .padding(.horizontal, .space(.medium))
                createContentsDivider()
                createTagsSectionView()
                    .padding(.horizontal, .space(.medium))
                createContentsDivider()
                createTrainingResultSectionView(store.totalTrainingResult)
                    .padding(.horizontal, .space(.medium))
                createContentsDivider()
                createResultPerTrainingSectionView(store.trainings)
            }
        }
    }
    
    func createTitleView() -> some View {
        Text(store.title)
            .font(.macho(.title))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func createMessageView() -> some View {
        OmittableMessageView(store.message)
            .font(.macho(.description))
    }
    
    func createTagsSectionView() -> some View {
        VStack(spacing: .space(.small)) {
            Text("Tags")
                .font(.macho(.subTitle))
                .frame(maxWidth: .infinity, alignment: .leading)
            FlowLayout(alignment: .leading, spacing: .space(.small)) {
                ForEach(store.tags) {
                    Text($0.tagName)
                        .font(.macho(.description))
                        .padding(.vertical, .space(.small))
                        .padding(.horizontal, .space(.small))
                        .foregroundStyle(Color(asset: CustomColor.tagForegroundColor))
                        .background(Color(asset: CustomColor.tagBackgroundColor))
                        .clipShape(RoundedRectangle(cornerRadius: tagCornerRadius))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    func createTrainingResultSectionView(_ trainingResult: TotalTrainingResult) -> some View {
        VStack(alignment: .leading, spacing: .space(.medium)) {
            Text("Training")
                .font(.macho(.subTitle))
                .frame(maxWidth: .infinity,
                       alignment: .leading)
            DiaryStatusIconView(status: store.diary.status,
                                size: achievedIconFontSize)
            VStack(alignment: .leading, spacing: .space(.small)) {
                Text("種目数：\(trainingResult.trainingCount)")
                Text("トレーニング日：\(trainingResult.startDateDisplayText)")
                Text("総トレーニング時間：\(trainingResult.totalTrainingTimeDurationText)")
            }
            .font(.macho(.description))
        }
    }
    
    func createResultPerTrainingSectionView(_ trainingResultList: [Goal]) -> some View {
        VStack(alignment: .leading, spacing: .space(.medium)) {
            ForEach(trainingResultList) {
                createResultPerTrainingItemView($0)
                Spacer()
                    .frame(height: .space(.small))
                createBasicDivider()
                    .opacity(trainingItemDividerOpacity)
            }
        }
    }
    
    func createResultPerTrainingItemView(_ resultItem: Goal) -> some View {
        HStack(spacing: .zero) {
            Text(resultItem.trainingType.name)
                .font(.macho(.subTitle))
                .frame(maxHeight: .infinity,
                       alignment: .topLeading)
            Spacer()
                .frame(width: .space(.medium))
            VStack(spacing: .zero) {
                Spacer()
                Text("目標\(String(format: resultDescriptionTextFormat, resultItem.setCount, resultItem.numberOfSets))")
                Text("達成セット数: \(resultItem.actualSetCount)")
            }
            .font(.macho(.description))
            Spacer()
            if store.isFinishedTraining {
                AchieveIconView(isAchieved: resultItem.isAchieved, size: achievedIconFontSize)
            }
        }
        .padding(.horizontal, .space(.medium))
    }
    
    func createContentsDivider() -> some View {
        VStack(spacing: .space(.medium)) {
            Spacer()
            createBasicDivider()
            Spacer()
        }
    }
    
    func createBasicDivider() -> some View {
        Rectangle()
            .ignoresSafeArea()
            .frame(
                maxWidth: .infinity,
                maxHeight: dividerHeight)
    }
}

// MARK: - preview

#Preview("トレーニング完了") {
    let goal1 = Goal(
        id: UUID(),
        trainingType: .init(id: UUID(), name: "腹筋"),
        numberOfSets: 3,
        setCount: 3,
        actualSetCount: 3
    )
    let tag1 = Tag(id: UUID(), tagName: "XXX")
    let tag2 = Tag(id: UUID(), tagName: "ZZZZZZZ")
    let tag3 = Tag(id: UUID(), tagName: "UUUUU")
    let initialDiaryEntity = Diary(
        id: UUID(),
        createdAt: .now,
        title: "Preview",
        mainText: "preview sample message",
        goals: [goal1],
        tags: [tag1, tag2, tag3],
        endTime: Date()
    )
    NavigationView {
        DiaryDetailView(
            store: Store(
                initialState: DiaryDetailFeature.State(diary: initialDiaryEntity),
                reducer: { DiaryDetailFeature() }
            )
        )
    }
}

#Preview("トレーニング中") {
    let goal1 = Goal(
        id: UUID(),
        trainingType: .init(id: UUID(), name: "腹筋"),
        numberOfSets: 3,
        setCount: 3,
        actualSetCount: 3
    )
    let initialDiaryEntity = Diary(
        id: UUID(),
        createdAt: .now,
        title: "Preview",
        mainText: "preview sample message",
        goals: [goal1],
        tags: [],
        endTime: nil
    )
    NavigationView {
        DiaryDetailView(
            store: Store(
                initialState: DiaryDetailFeature.State(diary: initialDiaryEntity),
                reducer: { DiaryDetailFeature() }
            )
        )
    }
}
