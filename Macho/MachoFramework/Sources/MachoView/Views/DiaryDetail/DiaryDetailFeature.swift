//
//  DiaryDetailFeature.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/10/19.
//

import Combine
import ComposableArchitecture
import Foundation
import RealmHelper

@Reducer
struct DiaryDetailFeature {
    
    // MARK: - Cancellable definition
    
    // フィルターテーブル監視のCancellable
    struct DiaryObserveCancellable: Hashable {}
    
    // MARK: - State
        
    @ObservableState
    struct State: Equatable {
        
        static func == (lhs: DiaryDetailFeature.State, rhs: DiaryDetailFeature.State) -> Bool {
            
            return lhs.diary.id == rhs.diary.id
        }
        
        // MARK: path
        
        var path = StackState<Path.State>()
        
        // MARK: view state
        
        var diary: DiaryEntity
        /// メッセージをさらに表示しているかどうか
        var isShownMoreMessage = false
        /// 日記のタイトル
        var title: String { diary.title }
        /// 日記のメッセージ
        var message: String { diary.mainText }
        /// 日記のタグ
        var tags: [TrainingTagEntity] { diary.tags }
        /// 日記に設定したトレーニングの総合結果
        var totalResult: TotalTrainingResult { TotalTrainingResult(diary) }
        /// 日記に設定したトレーニング種目毎の結果
        var trainings: [TrainingTypeResult] { diary.goals.map { TrainingTypeResult(goal: $0) } }
    }
    
    // MARK: - Action
    
    enum Action {
        
        // MARK: Navigation Action
        
        case path(StackActionOf<Path>)
        
        // MARK: Event Action
        
        /// 画面表示時
        case onAppear
        /// 画面非表示時
        case onDisappear
        /// 編集ボタン押下時
        case tappedEditButton
        /// さらに表示ボタン押下時
        case tappedShowMoreMessageButton
        
        // MARK: Effect Action
        
        /// 日記の取得副作用
        case didReceivedDiary(DiaryEntity)
    }
    
    // MARK: - Dependency
    
    @Dependency(\.diaryListFetchApi) var diaryListItemApi
    
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
                state.path.append(.editDiaryView(.init(contact: .init(id: UUID(), name: "sample"))))
                return .none
                
            case .tappedShowMoreMessageButton:
                state.isShownMoreMessage.toggle()
                return .none
                
            case .didReceivedDiary(let diary):
                state.diary = diary
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
        
        // TODO: dependencyから取得したDiaryEntityのPublisherを使用するようにする
        return .publisher {
            PassthroughSubject<[DiaryEntity], Never>()
                .compactMap { $0.first { $0.id == state.diary.id } }
                .map { Action.didReceivedDiary($0) }
                .eraseToAnyPublisher()
        }
        .cancellable(id: DiaryObserveCancellable())
    }
}
