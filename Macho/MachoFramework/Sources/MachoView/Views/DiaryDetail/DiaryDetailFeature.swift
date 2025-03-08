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
        private(set) var tags: [TrainingTagData]
        /// 日記に設定したトレーニングの総合結果
        private(set) var totalResult: TotalTrainingResult
        /// 日記に設定したトレーニング種目毎の結果
        private(set) var trainings: [TrainingTypeResult]
    }
    
    // MARK: - Action
    
    enum Action: Equatable, Sendable {
        
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
            
            logger.info("Did receive action: \(action)")
            
            switch action {
                
            case .path:
                return .none
                
            case .onAppear:
                return .run { send in
                    
                    guard let publisher = await diaryListItemApi.getDiaryObserver() else { return }
                    await send(.observePublisher(.observeDiaryList(publisher)))
                }
                
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
                
            case .observePublisher(.observeDiaryList(let publisher)):
                return addObserveDiaryData(publisher: publisher, targetId: state.diaryId)
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
    
    func addObserveDiaryData(publisher: AnyPublisher<[DiaryData], Never>,
                             targetId: UUID) -> EffectOf<Self> {
        
        return .publisher {
            
            publisher
                .compactMap { $0.first { $0.id == targetId } }
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
