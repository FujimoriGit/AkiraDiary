//
//  DiaryDetailFeature.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/10/19.
//

import Combine
import ComposableArchitecture
import Foundation

@Reducer
struct DiaryDetailFeature {
    
    // MARK: - Cancellable definition
    
    // フィルターテーブル監視のCancellable
    struct DiaryObserveCancellable: Hashable {}
    
    // MARK: - State
        
    @ObservableState
    struct State: Equatable {
        
        // MARK: path
        
        var path = StackState<Path.State>()
        
        // MARK: view state
        
        /// メッセージをさらに表示しているかどうか
        var isShownMoreMessage = false
        /// 日記EntityのID
        @ObservationStateIgnored let diaryId: UUID
        /// 日記のタイトル
        private(set) var title: String
        /// 日記のメッセージ
        private(set) var message: String
        /// 日記のタグ
        private(set) var tags: [Tag]
        /// 日記に設定したトレーニングの総合結果
        private(set) var totalResult: TotalTrainingResult
        /// 日記に設定したトレーニング種目毎の結果
        private(set) var trainings: [Goal]
    }
    
    // MARK: - Action
    
    enum Action: Equatable {
        
        // MARK: Navigation Action
        
        case path(StackActionOf<Path>)
        
        // MARK: Event Action
        
        /// 画面表示時
        case onAppear
        /// 画面非表示時
        case onDisappear
        /// 編集ボタン押下時
        case tappedEditButton
        /// 戻るボタン押下時
        case tappedBackNavigationButton
        
        // MARK: Effect Action
        
        /// 日記の取得副作用
        case didReceivedDiary(DiaryData)
    }
    
    // MARK: - Dependency
    
    @Dependency(\.diaryListFetchApi) var diaryListItemApi
    @Dependency(\.dismiss) var dismiss
    
    // MARK: - Reducer
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            
            logger.info("Did receive action: \(action)")
            
            switch action {
                
            case .path:
                return .none
                
            case .onAppear:
                return addObserveDiaryData(state)
                
            case .onDisappear:
                return .cancel(id: DiaryObserveCancellable())
                
            case .tappedEditButton:
                // TODO: 編集画面ができたら正しいStateを設定する
                state.path.append(.editDiaryView(.init(contact: .init(id: .init(.zero), name: "sample"))))
                return .none
                
            case .tappedBackNavigationButton:
                return .concatenate(
                    .cancel(id: DiaryObserveCancellable()),
                    .run { _ in
                        
                        await dismiss()
                    }
                )
                
            case .didReceivedDiary(let diary):
                state.updateDiary(diary)
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

// MARK: Navigation Path Definition

extension DiaryDetailFeature {
    
    @Reducer(state: .equatable, action: .equatable)
    enum Path: Equatable {
        
        // TODO: 編集画面ができたら変更する
        case editDiaryView(AddContactFeature)
        
        var id: Int {
            
            switch self {
                
            case .editDiaryView:
                return 0
            }
        }
        
        static func == (lhs: DiaryDetailFeature.Path, rhs: DiaryDetailFeature.Path) -> Bool {
            
            return lhs.id == rhs.id
        }
    }
}

// MARK: - private method

private extension DiaryDetailFeature {
    
    func addObserveDiaryData(_ state: State) -> EffectOf<Self> {
        
        return .publisher {
            diaryListItemApi.observeDiaryList()
                .compactMap { $0.first { $0.id == state.diaryId } }
                .map { Action.didReceivedDiary($0) }
                .eraseToAnyPublisher()
        }
        .cancellable(id: DiaryObserveCancellable())
    }
}

extension DiaryDetailFeature.State {
    
    init(diary: DiaryData) {
        
        diaryId = diary.id
        title = diary.title
        message = diary.mainText
        tags = diary.tags.map { TagConverter.toTag($0) }
        totalResult = TotalTrainingResult(diary)
        trainings = diary.goals.compactMap { GoalConverter.toGoal($0) }
    }
    
    mutating func updateDiary(_ diary: DiaryData) {
        
        title = diary.title
        message = diary.mainText
        tags = diary.tags.map { TagConverter.toTag($0) }
        totalResult = TotalTrainingResult(diary)
        trainings = diary.goals.compactMap { GoalConverter.toGoal($0) }
    }
}
