//
//  DiaryDetailFeature.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/10/19.
//

@preconcurrency import Combine
import ComposableArchitecture
import Foundation
import MachoCore

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
        /// 日記
        var diary: Diary
        /// 日記のタイトル
        var title: String { diary.title }
        /// 日記のメッセージ
        var message: String { diary.mainText }
        /// 日記のタグ
        var tags: [Tag] { diary.tags }
        /// 日記に設定したトレーニング種目毎の結果
        var trainings: [Goal] { diary.goals }
        /// トレーニング結果のメタ情報
        var totalTrainingResult: TotalTrainingResult
        /// トレーニングが完了しているかどうか
        var isFinishedTraining: Bool { diary.status.isFinished }
    }
    
    // MARK: - Action
    
    enum Action: Equatable, Sendable {
        
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
        /// 監視イベント
        case observePublisher(PublisherEvent)
        
        @CasePathable
        enum PublisherEvent: Equatable, Sendable {
            
            /// 日記の監視
            case observeDiaryList(AnyPublisher<[DiaryData], Never>)
            
            static func == (lhs: Self, rhs: Self) -> Bool {
                
                return lhs.is(\.observeDiaryList) == rhs.is(\.observeDiaryList)
            }
        }
    }
    
    // MARK: - Dependency
    
    @Dependency(\.diaryEntityClient) var diaryListItemApi
    @Dependency(\.dismiss) var dismiss
    
    // MARK: - Reducer
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            
            switch action {
                
            case .onAppear:
                return .run { send in
                    
                    guard let publisher = await diaryListItemApi.getDiaryObserver() else { return }
                    await send(.observePublisher(.observeDiaryList(publisher)))
                }
                
            case .tappedEditButton:
                state.navigationDestination = .editDiary(.init(editTarget: state.diary))
                return .cancel(id: DiaryObserveCancellable())
                
            case .tappedBackNavigationButton:
                return .concatenate(
                    .cancel(id: DiaryObserveCancellable()),
                    .run { _ in
                        
                        await dismiss()
                    }
                )
                
            case .didReceivedDiary(let entity):
                state.updateDiary(DiaryConverter.toDiary(entity))
                return .none
                
            case .observePublisher(.observeDiaryList(let publisher)):
                return addObserveDiaryData(
                    publisher: publisher,
                    targetId: state.diary.id)
                
            case .navigationDestination:
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
        
        case editDiary(DiaryCreationFeature)
    }
}

// MARK: - private method

extension DiaryDetailFeature {
    
    fileprivate func addObserveDiaryData(
        publisher: AnyPublisher<[DiaryData], Never>,
        targetId: UUID
    ) -> EffectOf<Self> {
        
        return .publisher {
            publisher
                .receive(on: DispatchQueue.main)
                .compactMap { $0.first { $0.id == targetId } }
                .map { Action.didReceivedDiary($0) }
                .eraseToAnyPublisher()
        }
        .cancellable(id: DiaryObserveCancellable())
    }
}

extension DiaryDetailFeature.State {
    
    init(diary: Diary) {
        
        self.diary = diary
        totalTrainingResult = TotalTrainingResult(diary)
    }
    
    mutating func updateDiary(_ diary: Diary) {
        
        self.diary = diary
        totalTrainingResult = TotalTrainingResult(diary)
    }
}
