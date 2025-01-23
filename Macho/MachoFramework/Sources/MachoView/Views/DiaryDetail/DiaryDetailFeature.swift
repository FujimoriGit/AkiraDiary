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
        
        @Presents var navigationDestination: Path.State?
        
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
        private(set) var tags: [TrainingTagData]
        /// 日記に設定したトレーニングの総合結果
        private(set) var totalResult: TotalTrainingResult
        /// 日記に設定したトレーニング種目毎の結果
        private(set) var trainings: [TrainingTypeResult]
    }
    
    // MARK: - Action
    
    enum Action: Equatable {
        
        // MARK: Navigation Action
        
        case navigationDestination(PresentationAction<Path.Action>)
        
        // MARK: Event Action
        
        /// 画面表示時
        case onAppear
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
                
            case .navigationDestination:
                return .none
                
            case .onAppear:
                return addObserveDiaryData(state)
                
            case .tappedEditButton:
                // TODO: 編集画面ができたら正しいStateを設定する
                state.navigationDestination = .editDiaryView(.init(contact: .init(id: .init(.zero), name: "sample")))
                return .cancel(id: DiaryObserveCancellable())
                
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
        .ifLet(\.$navigationDestination, action: \.navigationDestination)
    }
}

// MARK: Navigation Path Definition

extension DiaryDetailFeature {
    
    @Reducer(state: .equatable, action: .equatable)
    enum Path {
        
        // TODO: 編集画面ができたら変更する
        case editDiaryView(AddContactFeature)
    }
}

// MARK: - private method

private extension DiaryDetailFeature {
    
    func addObserveDiaryData(_ state: State) -> EffectOf<Self> {
        
        return .publisher {
            diaryListItemApi.observeDiaryList()
                .receive(on: DispatchQueue.main)
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
        tags = diary.tags
        totalResult = TotalTrainingResult(diary)
        trainings = diary.goals.map { TrainingTypeResult($0) }
    }
    
    mutating func updateDiary(_ diary: DiaryData) {
        
        title = diary.title
        message = diary.mainText
        tags = diary.tags
        totalResult = TotalTrainingResult(diary)
        trainings = diary.goals.map { TrainingTypeResult($0) }
    }
}
