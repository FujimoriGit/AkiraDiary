//
//  DiaryListFeature.swift
//  Macho
//
//  Created by 佐藤汰一 on 2024/01/07.
//

import ComposableArchitecture
import Foundation

@Reducer
struct DiaryListFeature: Sendable {
    
    // MARK: - Cancellable
    
    // フィルターテーブル監視のCancellable
    struct FilterObserveCancellable: Hashable {}
    
    // MARK: - State
    
    @ObservableState
    struct State: Equatable, Sendable {
        
        // MARK: Presents States
        
        @Presents var alert: AlertState<Action.Alert>?
        @Presents var destination: Destination.State?
        
        // MARK: Navigation States
        
        var path = StackState<Path.State>()
        
        // MARK: Component States
        
        /// フィルター反映後の日記リスト
        var filteredDiaries = IdentifiedArrayOf<DiaryListItemFeature.State>()
        /// 日記リストに表示する日記の項目の要素
        @ObservationStateIgnored var diaries = IdentifiedArrayOf<DiaryListItemFeature.State>()
        /// スクロール位置追跡リストのコンポーネントState
        @ObservationStateIgnored var trackableList = TrackableListFeature.State()
        
        // MARK: Observed State
        
        /// 日記リスト画面で監視したいプロパティを持つState
        var viewState = ViewState()
        /// 日記リストに表示する日記のフィルター設定
        var currentFilters: [DiaryListFilterItem] = []
        
        // MARK: computed property
        
        var canReloadWithScroll: Bool {
            
            // バウンスしているかつ、ロード中でない場合は日記リストの追加取得が行える状態と判断する
            return trackableList.isBouncedAtBottom && !viewState.isLoadingDiaries
        }
        
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
        /// 画面非表示時のアクション
        case onDisappearView
        /// フィルターボタン押下時のアクション
        case tappedFilterButton
        /// グラフボタン押下時のアクション
        case tappedGraphButton
        /// 新規アイテム追加ボタン押下時のアクション
        case tappedCreateNewDiaryButton
        
        // MARK: Effect Actions
        
        /// 日記リストの取得に成功したときの副作用を処理する
        case receiveLoadDiaryItems(items: [DiaryData])
        /// 指定した日記をRealmから削除する副作用を処理する
        case deletedDiaryItem(id: UUID)
        /// 日記リストのフィルター取得に成功した時の副作用を処理する
        case receiveLoadDiaryListFilter(filters: [DiaryListFilterItem])
        
        enum Alert: Equatable {
            
            /// 日記の編集を行うかどうかの確認アラート
            case confirmEditItem(targetId: UUID)
            /// 日記削除を行うかどうかの確認アラート
            case confirmDeleteItem(deleteItemId: UUID)
        }
    }
    
    // MARK: - private property
    
    // MARK: dependency property
    
    @Dependency(\.diaryListFetchApi) var diaryListFetchClient
    @Dependency(\.diaryListFilterApi) var diaryListFilterApi
    @Dependency(\.date) var date
    @Dependency(\.uuid) var uuid
    
    // MARK: other property
    
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
            .forEach(\.filteredDiaries, action: \.diaries) {
                
                DiaryListItemFeature()
            }
            .forEach(\.path, action: \.path)
            .ifLet(\.$destination, action: \.destination)
            .ifLet(\.$alert, action: \.alert)
    }
}

// MARK: - Main Action Handler

private extension DiaryListFeature {
    
    // swiftlint:disable:next function_body_length
    func createActionHandler() -> some ReducerOf<Self> {
        
        // swiftlint:disable:next closure_body_length
        Reduce { state, action in
            
            switch action {
                
            case .alert(.presented(.confirmEditItem(targetId: let id))):
                // TODO: 編集画面への遷移を実装する
                logger.info("confirmEditItem(id=\(id)).")
                state.path.append(.editScreen(AddContactFeature.State(contact: .init(id: uuid.callAsFunction(),
                                                                                     name: ""))))
                return .none
                
            case .alert(.presented(.confirmDeleteItem(deleteItemId: let id))):
                return deleteDiaryListItem(id)
                
            case .alert:
                return .none
                
            case let .destination(.presented(.filterScreen(delegate))):
                if needDismissFilterView(delegate) {
                    
                    state.destination = nil
                }
                
                return .none
                
            case .destination:
                return .none
                
            case .path:
                return .none
                
            case .onAppearView:
                logger.info("onAppearView")
                state.viewState.isLoadingDiaries = true
                return initialLoadDiaryListInfo()
                
            case .onDisappearView:
                logger.info("onDisappearView")
                return .cancel(id: FilterObserveCancellable())
                
                // 日記項目のComponentのDelegateAction
            case .diaries(.element(let id, let delegateAction)):
                logger.info("diaries delegate action(id: \(id), action: \(delegateAction)).")
                state = getUpdatedStateOnDiaryListItemDelegate(state: state,
                                                               delegate: delegateAction,
                                                               id: id)
                return .none
                
            case .trackableList(.onScroll):
                // Stateの更新
                state.viewState.isScrolling = state.trackableList.isScrolling
                
                guard state.canReloadWithScroll else { return .none }
                
                logger.debug("start loading diary items with list scroll.")
                
                // ロード中にStateを更新する
                state.viewState.isLoadingDiaries = true
                // バウンスした際はデータをリロードする
                return loadDiaryListItem(state.diaries.last?.date ?? date.now)
                
            case .trackableList:
                return .none
                
            case .tappedFilterButton:
                logger.info("tappedFilterButton")
                state.destination = .filterScreen(.init())
                return .none
                
            case .tappedGraphButton:
                logger.info("tappedGraphButton")
                // TODO: グラフ画面表示を実行
                state.path.append(.graphScreen(AddContactFeature.State(contact: .init(id: uuid.callAsFunction(),
                                                                                      name: ""))))
                return .none
                
            case .tappedCreateNewDiaryButton:
                logger.info("tappedCreateNewDiaryButton")
                // TODO: 日記作成画面表示を実行
                state.path.append(.createScreen(DiaryCreationFeature.State()))
                return .none
                
            case .receiveLoadDiaryItems(let items):
                logger.info("receiveLoadDiaryItems(items: \(items))")
                // stateの更新
                state = getUpdatedStateAfterReloadDiary(receive: items, state: state)
                return .none
                
            case .deletedDiaryItem(let id):
                logger.info("deletedDiaryItem(id: \(id))")
                // 日記リストの更新
                state.diaries.remove(id: id)
                state = updateDiaries(newDiaries: state.diaries, state: state)
                // 日記リストの有無更新
                state.viewState.hasDiaryItems = !state.filteredDiaries.isEmpty
                
                return .none
                
            case .receiveLoadDiaryListFilter(let filters):
                logger.info("receiveLoadDiaryListFilter(filters: \(filters))")
                
                // 現在のフィルターを更新
                state.currentFilters = filters
                // 日記リストが存在しない場合は何もしない
                if state.diaries.isEmpty { return .none }
                // 日記リストのフィルター反映
                state = updateDiaries(newDiaries: state.diaries, state: state)
                
                return .none
            }
        }
    }
}

// MARK: - Path Destination Definition

extension DiaryListFeature {
    
    @Reducer(state: .equatable, action: .equatable)
    enum Path: Equatable {
        
        // 日記編集画面
        case editScreen(AddContactFeature)
        // 日記作成画面
        case createScreen(DiaryCreationFeature)
        // グラフ画面
        case graphScreen(AddContactFeature)
        // 詳細画面
        case detailScreen(DiaryDetailFeature)
        
        var id: Int {
            
            switch self {
                
            case .editScreen:
                return 0
                
            case .createScreen:
                return 1
                
            case .graphScreen:
                return 2
                
            case .detailScreen:
                return 3
            }
        }
        
        static func == (lhs: DiaryListFeature.Path, rhs: DiaryListFeature.Path) -> Bool {
            
            return lhs.id == rhs.id
        }
    }
}

// MARK: - Presentation Destination Definition

extension DiaryListFeature {
    
    @Reducer(state: .equatable, action: .equatable)
    enum Destination: Equatable {
        
        // フィルター画面
        case filterScreen(DiaryListFilterFeature)
        
        var id: Int {
            
            switch self {
                
            case .filterScreen:
                return 0
            }
        }
        
        static func == (lhs: DiaryListFeature.Destination, rhs: DiaryListFeature.Destination) -> Bool {
            
            return lhs.id == rhs.id
        }
    }
}

// MARK: - Private Methods

private extension DiaryListFeature {
    
    /// 日記リスト初回表示時に必要な情報のロードを行う
    /// - Returns: 副作用を返す
    func initialLoadDiaryListInfo() -> Effect<DiaryListFeature.Action> {
        
        return .concatenate(
            .run { send in
                
                let currentFilterList = await diaryListFilterApi.fetchFilterList()
                return await send(.receiveLoadDiaryListFilter(filters: currentFilterList))
            },
            loadDiaryListItem(date.now),
            .publisher {
                
                return diaryListFilterApi.getFilterListObserver()
                    .receive(on: DispatchQueue.main)
                    .map { .receiveLoadDiaryListFilter(filters: $0) }
            }.cancellable(id: FilterObserveCancellable())
        )
    }
    
    /// 日記リスト取得の副作用を返す
    /// - Parameter startDate: 日記取得の開始日付
    /// - Returns: 日記取得の副作用を返す
    func loadDiaryListItem(_ startDate: Date) -> Effect<DiaryListFeature.Action> {
        
        return .run { send in
            
            let diaryItems = await diaryListFetchClient.fetch(startDate, limitFetchDiary)
            await send(.receiveLoadDiaryItems(items: diaryItems),
                       animation: .spring)
        }
    }
    
    /// 日記リストのリロード処理後の更新したStateを返す
    /// - Parameters:
    ///   - receive: 日記リストのリロードで取得したリスト
    ///   - state: 更新前のState
    func getUpdatedStateAfterReloadDiary(receive diaries: [DiaryData], state: State) -> State {
        
        var updatedState = state
        // Stateの更新
        diaries.forEach { updatedState.diaries.updateOrAppend(.init($0)) }
        updatedState = updateDiaries(newDiaries: updatedState.diaries, state: updatedState)
        // リロード中フラグを倒す
        updatedState.viewState.isLoadingDiaries = false
        // 表示中リスト有無のフラグ更新
        updatedState.viewState.hasDiaryItems = !updatedState.filteredDiaries.isEmpty
        
        logger.debug("did end update diaries(\(state.diaries))")
        return updatedState
    }
    
    func updateDiaries(newDiaries: IdentifiedArrayOf<DiaryListItemFeature.State>, state: State) -> State {
        
        var updatedState = state
        
        // 日記の作成日付で降順にソートする
        updatedState.diaries = newDiaries
        updatedState.diaries.sort { $0.date > $1.date }
        // フィルターの反映
        updatedState.filteredDiaries = getFilteringDiaryList(diaryList: updatedState.diaries,
                                                                  filters: updatedState.currentFilters)
        return updatedState
    }
    
    /// フィルターを反映した日記リストのを返す
    /// - Parameters:
    ///   - diaryList: 更新対象の日記リスト
    ///   - filters: フィルター
    func getFilteringDiaryList(diaryList: IdentifiedArrayOf<DiaryListItemFeature.State>,
                               filters: [DiaryListFilterItem]) -> IdentifiedArrayOf<DiaryListItemFeature.State> {
        
        // フィルタリング処理
        let filteredList = diaryList.filter { item in
            
            return filters.isEmpty ? true : filters.contains {
                $0.isMatchFilter(isAchieved: item.isWin,
                                 trainingList: item.trainingList,
                                 tagList: item.tagList)
            }
        }
        
        logger.debug("did finish filtering(before: \(diaryList), after: \(filteredList), filter: \(filters))")
        return filteredList
    }
    
    func needDismissFilterView(_ delegate: DiaryListFilterFeature.Action) -> Bool {
        
        switch delegate {
            
        case .tappedOutsideArea, .tappedCloseButton:
            return true
            
        default:
            return false
        }
    }
    
    func deleteDiaryListItem(_ id: UUID) -> Effect<DiaryListFeature.Action> {
        
        logger.info("confirmDeleteItem(id=\(id)).")
        
        return .run { send in
            
            try await diaryListFetchClient.deleteItem(id)
            await send(.deletedDiaryItem(id: id), animation: .spring)
        }
    }
    
    func getUpdatedStateOnDiaryListItemDelegate(state: State,
                                                delegate: DiaryListItemFeature.Action,
                                                id: UUID) -> State {
        
        var updateTargetState = state
        
        switch delegate {
            
        case .tappedDiaryItem:
            if let diary = state.diaries.first(where: { $0.id == id }) {
                
                updateTargetState.path.append(.detailScreen(.init(diary: diary.entity)))
            }
            
        case .deleteItemSwipeAction:
            // アラート表示
            updateTargetState.alert = .createAlertStateWithCancel(.deleteDiaryItemConfirmAlert,
                                                                  firstButtonHandler: 
                    .confirmDeleteItem(deleteItemId: id))
            
        case .editItemSwipeAction:
            // アラート表示
            updateTargetState.alert = .createAlertStateWithCancel(.editDiaryItemConfirmAlert,
                                                                  firstButtonHandler: .confirmEditItem(targetId: id))
        }
        
        return updateTargetState
    }
}
