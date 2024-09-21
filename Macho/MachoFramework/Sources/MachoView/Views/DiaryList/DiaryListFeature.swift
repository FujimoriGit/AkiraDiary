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
    
    // MARK: - State
    
    struct State: Equatable, Sendable {
        
        // MARK: Presents States
        
        @PresentationState var alert: AlertState<Action.Alert>?
        @PresentationState var destination: Destination.State?
        
        // MARK: Navigation States
        
        var path = StackState<Path.State>()
        
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
            /// 日記リストの読み込み中かどうか
            var isLoadingDiaries = false
            /// 表示する日記リストがあるかどうか
            var hasDiaryItems = false
        }
    }
    
    // MARK: - Action
    
    enum Action: Sendable, Equatable {
        
        // MARK: Presentation Action
        
        /// アラートの表示
        case alert(PresentationAction<Alert>)
        /// モーダル遷移による画面表示
        case destination(PresentationAction<Destination.Action>)
        
        // MARK: Navigation Action
        
        case path(StackAction<Path.State, Path.Action>)
        
        // MARK: Component Actions
        
        /// 日記一覧のリスト
        case diaries(IdentifiedActionOf<DiaryListItemFeature>)
        /// スクロール位置追跡リストのコンポーネント
        case trackableList(TrackableListFeature.Action)
        
        // MARK: Event Actions
        
        /// 画面表示時のアクション
        case onAppearView
        /// フィルターボタン押下時のアクション
        case tappedFilterButton
        /// グラフボタン押下時のアクション
        case tappedGraphButton
        /// 新規アイテム追加ボタン押下時のアクション
        case tappedCreateNewDiaryButton
        
        // MARK: Effect Actions
        
        /// 日記リストの取得に成功したときの副作用を処理する
        case receiveLoadDiaryItems(items: [DiaryListItemFeature.State])
        /// 日記リストの取得に失敗したときの副作用を処理する
        case failedLoadDiaryItems
        /// 指定した日記をRealmから削除する副作用を処理する
        case deletedDiaryItem(id: UUID)
        
        @CasePathable
        enum Alert: Equatable {
            
            /// 日記リストの取得失敗時のアラート
            case failedLoadDiaryItems
            /// 日記の編集を行うかどうかの確認アラート
            case confirmEditItem(targetId: UUID)
            /// 日記削除を行うかどうかの確認アラート
            case confirmDeleteItem(deleteItemId: UUID)
        }
    }
    
    // MARK: - private property
    
    // MARK: dependency property
    
    @Dependency(\.diaryListFetchApi) var diaryListFetchCliant
    @Dependency(\.date) var date
    @Dependency(\.uuid) var uuid
    
    // MARK: other proeprty
    
    // 日記リスト取得処理の取得制限個数
    private let limitFetchDiary = 20
    
    // MARK: - Reducer
    
    var body: some ReducerOf<Self> {
        
        // スクロール位置トラッキングできるListViewコンポーネントの追加
        Scope(state: \.trackableList, action: \.trackableList) {
            TrackableListFeature()
        }
        
        // Actionハンドラ追加
        createActionHandler()
        .forEach(\.diaries, action: \.diaries) {
            
            DiaryListItemFeature()
        }
        .forEach(\.path, action: \.path) {
            
            Path()
        }
        .ifLet(\.$destination, action: \.destination) {
            
            // TODO: フィルター画面に置き換える
            Destination()
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

// MARK: - Main Action Handler

private extension DiaryListFeature {
    
    func createActionHandler() -> some ReducerOf<Self> {
        
        Reduce { state, action in
            
            switch action {
                
            case .alert(.presented(let alertType)):
                
                switch alertType {
                    
                case .confirmEditItem(let id):
                    // TODO: 編集画面への遷移を実装する
                    logger.info("confirmEditItem(id=\(id)).")
                    state.path.append(.editScreen(AddContactFeature.State(contact: .init(id: uuid.callAsFunction(), name: ""))))
                    return .none
                    
                case .confirmDeleteItem(let id):
                    logger.info("confirmDeleteItem(id=\(id)).")
                    return .run { send in
                        
                        try await diaryListFetchCliant.deleteItem(id)
                        await send(.deletedDiaryItem(id: id), animation: .spring)
                    }
                    
                default:
                    return .none
                }
                
            case .alert:
                return .none
                
            case .destination:
                return .none
                
            case .path:
                return .none
                
            case .onAppearView:
                logger.info("onAppearView")
                state.viewState.isLoadingDiaries = true
                return loadDiaryListItem(date.now)
                
                // 日記項目のComponentのDelegateAction
            case .diaries(.element(let id, let delegateAction)):
                logger.info("diaries delegate action(id: \(id), action: \(delegateAction)).")
                switch delegateAction {
                    
                case .tappedDiaryItem:
                    // TODO: 日記詳細画面への遷移を実装する
                    logger.debug("show detail view.")
                    state.path.append(.detailScreen(AddContactFeature.State(contact: .init(id: uuid.callAsFunction(), name: ""))))
                    return .none
                    
                case .deleteItemSwipeAction:
                    // アラート表示
                    logger.debug("show delete confirm alert.")
                    state.alert = AlertState.createAlertStateWithCancel(.deleteDiaryItemConfirmAlert,
                                                                        firstButtonHandler: .confirmDeleteItem(deleteItemId: id))
                    return .none
                    
                case .editItemSwipeAction:
                    // アラート表示
                    logger.debug("show edit confirm alert.")
                    state.alert = AlertState.createAlertStateWithCancel(.editDiaryItemConfirmAlert,
                                                                        firstButtonHandler: .confirmEditItem(targetId: id))
                    return .none
                }
                
            case .trackableList(let delegateAction):
                // スクロールを検知した時
                if case .onScroll = delegateAction {
                    
                    // Stateの更新
                    state.viewState.isScrolling = state.trackableList.isScrolling
                    
                    // バウンスしていたかつ、ロード中でない場合は日記リストの追加取得を行う
                    if state.trackableList.isBouncedAtBottom,
                       !state.viewState.isLoadingDiaries {
                        
                        logger.debug("start loading diary items with list scroll.")
                        // ロード中にStateを更新する
                        state.viewState.isLoadingDiaries = true
                        
                        let startDate = state.diaries.last?.date ?? date.now
                        // バウンスした際はデータをリロードする
                        return loadDiaryListItem(startDate)
                    }
                }
                
                return .none
                
            case .tappedFilterButton:
                logger.info("tappedFilterButton")
                // TODO: フィルター表示処理を実行
                state.destination = Destination.State.filterScreen(.init(contact: .init(id: uuid.callAsFunction(), name: "")))
                return .none
                
            case .tappedGraphButton:
                logger.info("tappedGraphButton")
                // TODO: グラフ画面表示を実行
                state.path.append(.graphScreen(AddContactFeature.State(contact: .init(id: uuid.callAsFunction(), name: ""))))
                return .none
                
            case .tappedCreateNewDiaryButton:
                logger.info("tappedCreateNewDiaryButton")
                // TODO: 日記作成画面表示を実行
                state.path.append(.createScreen(AddContactFeature.State(contact: .init(id: uuid.callAsFunction(), name: ""))))
                return .none
                
            case .receiveLoadDiaryItems(let items):
                logger.info("receiveLoadDiaryItems(items: \(items))")
                
                // Stateの更新
                items.forEach { state.diaries.updateOrAppend($0) }
                // 日記の作成日付で降順にソートする
                state.diaries.sort { $0.date < $1.date }
                state.viewState.isLoadingDiaries = false
                state.viewState.hasDiaryItems = !items.isEmpty
                
                return .none
                
            case .failedLoadDiaryItems:
                logger.error("failedLoadDiaryItems")
                // ロード終了
                state.viewState.isLoadingDiaries = false
                // アラートを表示する
                state.alert = AlertState.createAlertState(.failedLoadDiaryItemsAlert, firstButtonHandler: .failedLoadDiaryItems)
                
                return .none
                
            case .deletedDiaryItem(let id):
                logger.info("deletedDiaryItem(id: \(id))")
                state.diaries.remove(id: id)
                state.viewState.hasDiaryItems = !state.diaries.isEmpty
                
                return .none
            }
        }
    }
}

// MARK: - Path Destination Definition

extension DiaryListFeature {
    
    @Reducer
    struct Path: Equatable {
        
        enum State: Equatable, Sendable {
            
            // 日記編集画面
            case editScreen(AddContactFeature.State)
            // 日記作成画面
            case createScreen(AddContactFeature.State)
            // グラフ画面
            case graphScreen(AddContactFeature.State)
            // 詳細画面
            case detailScreen(AddContactFeature.State)
        }
        
        enum Action: Equatable, Sendable {
            
            // 日記編集画面
            case editScreen(AddContactFeature.Action)
            // 日記作成画面
            case createScreen(AddContactFeature.Action)
            // グラフ画面
            case graphScreen(AddContactFeature.Action)
            // 詳細画面
            case detailScreen(AddContactFeature.Action)
        }
        
        var body: some ReducerOf<Self> {
            
            Scope(state: \.editScreen, action: \.editScreen) {
                
                // TODO: 編集画面に置き換える
                AddContactFeature()
            }
            Scope(state: \.createScreen, action: \.createScreen) {
                
                // TODO: 作成画面に置き換える
                AddContactFeature()
            }
            Scope(state: \.graphScreen, action: \.graphScreen) {
                
                // TODO: グラフ画面に置き換える
                AddContactFeature()
            }
            Scope(state: \.detailScreen, action: \.detailScreen) {
                
                // TODO: 詳細画面に置き換える
                AddContactFeature()
            }
        }
    }
}

// MARK: - Presentation Destination Definition
extension DiaryListFeature {
    
    @Reducer
    struct Destination {
        
        enum State: Equatable {
            
            // フィルター画面
            case filterScreen(AddContactFeature.State)
        }
        
        enum Action: Equatable {
            
            // フィルター画面
            case filterScreen(AddContactFeature.Action)
        }
        
        var body: some ReducerOf<Self> {
            
            Scope(state: \.filterScreen, action: \.filterScreen) {
                
                // TODO: フィルター画面に置き換える
                AddContactFeature()
            }
        }
    }
}

// MARK: - Private Methods

private extension DiaryListFeature {
    
    /// 日記リスト取得の副作用を返す
    /// - Parameter startDate: 日記取得の開始日付
    /// - Returns: 日記取得の副作用を返す
    func loadDiaryListItem(_ startDate: Date) -> Effect<DiaryListFeature.Action> {
                
        return .run { send in
            
            try await send(.receiveLoadDiaryItems(items: diaryListFetchCliant.fetch(startDate, limitFetchDiary)),
                           animation: .spring)
        } catch: { error, send in
            
            logger.error("Occurred loadDiaryListItem error(\(error)).")
            return await send(.failedLoadDiaryItems)
        }
    }
}
