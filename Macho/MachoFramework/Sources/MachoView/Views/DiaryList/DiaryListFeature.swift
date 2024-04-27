//
//  DiaryListFeature.swift
//  Macho
//
//  Created by 佐藤汰一 on 2024/01/07.
//

import ComposableArchitecture
import Foundation

@Reducer
struct DiaryListFeature: Reducer, Sendable {
    
    struct State: Equatable {
        
        // MARK: Component States
        
        /// 日記リストに表示する日記の項目の要素
        var diaries = IdentifiedArrayOf<DiaryListItemFeature.State>()
        /// スクロール位置追跡リストのコンポーネントState
        var trackableList = TrackableListFeature.State()
        
        // MARK: Observed State
        
        /// 日記リスト画面で監視したいプロパティを持つState
        var viewState = ViewState()
        
        struct ViewState: Equatable {
            
            /// スクロール中かどうか
            var isScrolling = false
            /// 日記リストのスクロールエリアのY軸のoffset
            var isBounced = false
            /// 日記リストの読み込み中かどうか
            var isLoadingDiaries = false
        }
    }
    
    enum Action: Sendable, Equatable {
        
        // MARK: Component Actions
        
        /// 日記一覧のリスト
        case diaries(IdentifiedActionOf<DiaryListItemFeature>)
        /// スクロール位置追跡リストのコンポーネント
        case trackableList(TrackableListFeature.Action)
        
        // MARK: Event Actions
        
        /// フィルターボタン押下時のアクション
        case tappedFilterButton
        /// グラフボタン押下時のアクション
        case tappedGraphButton
        /// 新規アイテム追加ボタン押下時のアクション
        case tappedCreateNewDiaryButton
        /// 日記リストがスクロールされたときのアクション
//        case onScrollDiaryList(isScrolling: Bool, isBounceAtBottom: Bool)
        
        // MARK: Effect Actions
        
        /// 日記リストの更新を受信する
        case receiveLoadDiaryItems(items: [DiaryListItemFeature.State])
    }
    
    @Dependency(\.diaryListFetchApi) var diaryListFetchCliant
    
    var body: some ReducerOf<Self> {
        
        Scope(state: \.trackableList, action: \.trackableList) {
            TrackableListFeature()
        }
        // リストのスクロール情報の監視
        .onChange(of: \.trackableList) { _, trackableListState in
            Reduce { state, action in
                
                // Stateの更新
                state.viewState.isScrolling = trackableListState.isScrolling
                state.viewState.isBounced = trackableListState.isBouncedAtBottom
                
                // バウンスしていたかつ、ロード中でない場合は日記リストの追加取得を行う
                if state.viewState.isBounced,
                   !state.viewState.isLoadingDiaries {
                    
                    print("start loading diary items.")
                    // ロード中にStateを更新する
                    state.viewState.isLoadingDiaries = true
                    
                    let startDate = state.diaries.last?.date ?? Date()
                    // バウンスした際はデータをリロードする
                    return loadDiaryListItem(startDate)
                }
                else {
                    
                    return .none
                }
            }
        }
        Reduce { state, action in
            
            switch action {
            
            // 日記項目のComponentのDelegateAction
            case .diaries(.element(let id, let delegateAction)):
                switch delegateAction {
                    
                case .tappedDiaryItem:
                    // TODO: 日記詳細画面への遷移を実装する
                    print("show detail view.")
                    return .none
                    
                case .deleteItemSwipeAction:
                    // TODO: Realmの処理実装後に、Realmの削除に同期してStateの更新をするようにする
                    state.diaries.removeAll { $0.id == id }
                    print("delete item(\(id)).")
                    
                    // TODO: アイテムを削除する処理を実行する
                    return .none
                    
                case .editItemSwipeAction:
                    // TODO: 編集画面への遷移を実装する
                    print("show edit view.")
                    
                    return .none
                }
                
            case .trackableList:
                return .none
                
            case .tappedFilterButton:
                // TODO: フィルター表示処理を実行
                state.diaries.append(.init(title: "filter", message: "test", date: Date(), isWin: true))
                return .none
                
            case .tappedGraphButton:
                // TODO: グラフ画面表示を実行
                state.diaries.append(.init(title: "graph", message: "test", date: Date(), isWin: true))
                return .none
                
            case .tappedCreateNewDiaryButton:
                // TODO: 日記作成画面表示を実行
                state.diaries.append(.init(title: "create", message: "test", date: Date(), isWin: true))
                return .none
                
            case .receiveLoadDiaryItems(let items):
                print("complete load diary items.")
                
                // Stateの更新
                state.diaries += items
                state.viewState.isLoadingDiaries = false
                
                return .none
                
//            case .onScrollDiaryList(let isScrolling, let isBouncedAtBottom):
                
            }
        }
        .forEach(\.diaries, action: \.diaries) {
            DiaryListItemFeature()
        }
    }
}

private extension DiaryListFeature {
    
    func loadDiaryListItem(_ startDate: Date) -> Effect<DiaryListFeature.Action> {
        
        // TODO: debug
        print("do loadDiaryListItem.")
        
        return .run { send in
            // TODO: リスト取得処理を行う
            try await send(.receiveLoadDiaryItems(items: diaryListFetchCliant.fetch(startDate)), animation: .spring)
        }
    }
}
