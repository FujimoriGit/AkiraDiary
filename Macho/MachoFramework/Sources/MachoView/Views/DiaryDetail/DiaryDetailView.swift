//
//  DiaryDetailView.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/10/26.
//

import ComposableArchitecture
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
    private let tagTextFontSize: CGFloat = 14
    
    private let contentsHorizontalPadding: CGFloat = 16
    private let titleBottomPadding: CGFloat = 18
    private let dividerTopPadding: CGFloat = 30
    private let dividerBottomPadding: CGFloat = 20
    private let trainingTotalResultSectionSpace: CGFloat = 16
    private let trainingTotalResultTextSpace: CGFloat = 8
    private let resultPerTrainingSectionVerticalSpace: CGFloat = 10
    private let trainingNameTrailingPadding: CGFloat = 16
    private let tagSectionVerticalPadding: CGFloat = 10
    private let tagsSpace: CGFloat = 8
    private let tagVerticalPadding: CGFloat = 4
    private let tagHorizontalPadding: CGFloat = 8
    
    private let dividerHeight: CGFloat = 1
    
    private let tagCornerRadius: CGFloat = 10
    
    private let defaultMessageLineLimit = 3
    private let resultDescriptionTextFormat = ":%dセット%d回"
    
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
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Detail")
        } destination: { store in
            switch store.case {
                
            case .editDiaryView(let store):
                // TODO: 仮の遷移先のため実装完了したら編集画面への遷移を実装する
                AddContactView(store: store)
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .onDisappear {
            store.send(.onDisappear)
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
                createBasicDivider()
                    .padding(.vertical, resultPerTrainingSectionVerticalSpace)
                createResultPerTrainingSectionView(store.trainings)
            }
        }
    }
    
    func createTitleView() -> some View {
        Text(store.title)
            .font(.system(size: titleFontSize, weight: .bold))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func createMessageView() -> some View {
        OmittableMessageView(store.message,
                             fontSize: messageFontSize)
    }
    
    func createTagsSectionView() -> some View {
        VStack(spacing: tagSectionVerticalPadding) {
            Text("Tags")
                .font(.system(size: sectionTitleFontSize,
                              weight: .bold))
                .frame(maxWidth: .infinity,
                       alignment: .leading)
            FlowLayout(alignment: .leading, spacing: tagsSpace) {
                ForEach(store.tags) {
                    // TODO: 色は仮(藤森さんの実装に合わせる)
                    Text($0.tagName)
                        .font(.system(size: tagTextFontSize))
                        .padding(.vertical, tagVerticalPadding)
                        .padding(.horizontal, tagHorizontalPadding)
                        .foregroundStyle(Color(asset: CustomColor.fillButtonForegroundColor))
                        .background(Color(asset: CustomColor.fillButtonBackgroundColor))
                        .clipShape(RoundedRectangle(cornerRadius: tagCornerRadius))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    func createTrainingResultSectionView(_ trainingResult: TotalTrainingResult) -> some View {
        VStack(alignment: .leading, spacing: trainingTotalResultSectionSpace) {
            Text("Training")
                .font(.system(size: sectionTitleFontSize,
                              weight: .bold))
                .frame(maxWidth: .infinity,
                       alignment: .leading)
            AchieveIconView(isAchieved: trainingResult.isAchievedTotalGoal,
                            size: achievedIconFontSize)
            VStack(alignment: .leading,
                   spacing: trainingTotalResultTextSpace) {
                Text("種目数：\(trainingResult.trainingCount)")
                Text("トレーニング開始時間：\(trainingResult.startDateDisplayText)")
                Text("トレーニング終了時間：\(trainingResult.endDateDisplayText)")
                Text("総トレーニング時間：\(trainingResult.totalTrainingTimeDurationText)")
            }
            .font(.system(size: trainingDetailTextFontSize))
        }
    }
    
    func createResultPerTrainingSectionView(_ trainingResultList: [Goal]) -> some View {
        VStack(alignment: .leading, spacing: resultPerTrainingSectionVerticalSpace) {
            ForEach(trainingResultList) {
                createResultPerTrainingItemView($0)
                createBasicDivider()
            }
        }
    }
    
    func createResultPerTrainingItemView(_ resultItem: Goal) -> some View {
        HStack(spacing: .zero) {
            Text(resultItem.trainingType.name)
                .font(.system(size: sectionTitleFontSize, weight: .bold))
                .frame(maxHeight: .infinity,
                       alignment: .topLeading)
            Spacer()
                .frame(width: trainingNameTrailingPadding)
            VStack(spacing: .zero) {
                Spacer()
                Text("目標\(String(format: resultDescriptionTextFormat, resultItem.setCount, resultItem.numberOfSets))")
                Text("達成セット数: \(resultItem.actualSetCount)")
            }
            .font(.system(size: trainingDetailTextFontSize))
            Spacer()
            AchieveIconView(isAchieved: resultItem.isAchieved,
                            size: achievedIconFontSize)
        }
        .padding(.horizontal, contentsHorizontalPadding)
    }
    
    func createContentsDivider() -> some View {
        VStack(spacing: .zero) {
            Spacer()
                .frame(height: dividerTopPadding)
            createBasicDivider()
            Spacer()
                .frame(height: dividerBottomPadding)
        }
    }
    
    func createBasicDivider() -> some View {
        Rectangle()
            .ignoresSafeArea()
            .frame(maxWidth: .infinity,
                   maxHeight: dividerHeight)
    }
}

// MARK: - preview

#Preview {
    let goal1 = TrainingContentData(id: UUID(),
                                    trainingType: TrainingTypeData(id: UUID(), name: "腹筋"),
                                    goalNumberOfSets: 3,
                                    goalSetCount: 3,
                                    actualNumberOfSets: 3,
                                    actualSetCount: 3)
    let tag1 = TrainingTagData(id: UUID(), tagName: "XXX")
    let tag2 = TrainingTagData(id: UUID(), tagName: "ZZZZZZZ")
    let tag3 = TrainingTagData(id: UUID(), tagName: "UUUUU")
    let initialDiaryEntity = DiaryData(id: UUID(),
                                       date: Date(),
                                       title: "Preview",
                                       // swiftlint:disable:next line_length
                                       mainText: "preview sample message\nxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
                                       goals: [goal1],
                                       tags: [tag1, tag2, tag3],
                                       startTime: Date(),
                                       endTime: Date())
    DiaryDetailView(store: Store(initialState: DiaryDetailFeature.State(diary: initialDiaryEntity),
                                 reducer: { DiaryDetailFeature() }))
}
