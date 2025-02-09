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
    
    // MARK: - State
    
    @ObservableState
    struct State: Equatable, Sendable {
        
        // MARK: Presents States
        
        @Presents var alert: AlertState<Action.Alert>?
        @Presents var destination: PopUpFeature<DiaryListFilterFeature>.State?
        
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
//        case destination(PresentationAction<Destination.Action>)
        case destination(PresentationAction<PopUpFeature<DiaryListFilterFeature>.Action>)
        
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
            .ifLet(\.$alert, action: \.alert)
            .ifLet(\.$destination, action: \.destination) {
                PopUpFeature<DiaryListFilterFeature>()
            }
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
                logger.info("tapped edit button(id=\(id)).")
                state.path = .toEditScreenPath
                return .none
                
            case .alert(.presented(.confirmDeleteItem(deleteItemId: let id))):
                return deleteDiaryListItem(id)
                
            case .alert:
                return .none
                
            case .destination(.presented(.childAction(.delegate(.confirmedFilter(let filters))))):
                return .run { send in
                    
                    await send(.receiveLoadDiaryListFilter(filters: filters))
                }
                
            case .destination:
                return .none
                
            case .path(.element(id: state.path.ids.last,
                                action: .graphScreen(.delegate(.tappedEmptyDiaryAlertButton)))):
                state.path = .toCreationScreenPath
                return .none
                
            case .path:
                return .none
                
            case .onAppearView:
                logger.info("onAppearView")
                state.viewState.isLoadingDiaries = true
                return initialLoadDiaryListInfo()
                
                // 日記項目のComponentのDelegateAction
            case .diaries(.element(let id, let delegateAction)):
                state = getUpdatedStateOnDiaryListItemDelegate(state: state,
                                                               delegate: delegateAction,
                                                               id: id)
                return .none
                
            case .trackableList(.onScroll):
                // Stateの更新
                state.viewState.isScrolling = state.trackableList.isScrolling
                
                guard state.canReloadWithScroll else { return .none }
                                
                // ロード中にStateを更新する
                state.viewState.isLoadingDiaries = true
                // バウンスした際はデータをリロードする
                return loadDiaryListItem(state.diaries.last?.date ?? date.now)
                
            case .trackableList:
                return .none
                
            case .tappedFilterButton:
                state.destination = .init(childState: .init())
                return .none
                
            case .tappedGraphButton:
                state.path = .toGraphScreenPath
                return .none
                
            case .tappedCreateNewDiaryButton:
                state.path = .toCreationScreenPath
                return .none
                
            case .receiveLoadDiaryItems(let fetchedDiaries):
                logger.info("receiveLoadDiaryItems(\(fetchedDiaries))")
                let diaryList = DiaryList(adding: fetchedDiaries,
                                          current: state.diaries.elements)
                state = getUpdatedDiaryList(updatedList: diaryList, currentState: state)
                // リロード中フラグを倒す
                state.viewState.isLoadingDiaries = false
                return .none
                
            case .deletedDiaryItem(let id):
                logger.info("deletedDiaryItem(id: \(id))")
                let diaryList = DiaryList(removing: id, current: state.diaries.elements)
                state = getUpdatedDiaryList(updatedList: diaryList, currentState: state)
                
                return .none
                
            case .receiveLoadDiaryListFilter(let filters):
                logger.info("receiveLoadDiaryListFilter(filters: \(filters))")
                
                // 現在のフィルターを更新
                state.currentFilters = filters
                // 日記リストのフィルター反映
                let diaryList = DiaryList(elements: state.diaries.elements)
                state = getUpdatedDiaryList(updatedList: diaryList, currentState: state)
                
                return .none
            }
        }
    }
}

// MARK: - Path Destination Definition

extension DiaryListFeature {
    
    @Reducer(state: .equatable, action: .equatable)
    enum Path {
        
        // 日記編集画面
        case editScreen(AddContactFeature)
        // 日記作成画面
        case createScreen(DiaryCreationFeature)
        // グラフ画面
        case graphScreen(TrainingActivityGraphFeature)
        // 詳細画面
        case detailScreen(DiaryDetailFeature)
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
                await send(.receiveLoadDiaryListFilter(filters: currentFilterList))
            },
            loadDiaryListItem(date.now)
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
    
    func getUpdatedDiaryList(updatedList: DiaryList, currentState: State) -> State {
        
        var updatedState = currentState
        updatedState.diaries = .init(uniqueElements: updatedList.elements)
        
        let filteredDiaryList = updatedList.getFilteredList(filters: currentState.currentFilters)
        updatedState.filteredDiaries = .init(
            uniqueElements: filteredDiaryList.elements
        )
        updatedState.viewState.hasDiaryItems = filteredDiaryList.hasElements
        return updatedState
    }
    
    func deleteDiaryListItem(_ id: UUID) -> Effect<DiaryListFeature.Action> {
                
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
                
                updateTargetState.path = .getToDetailScreenPath(diary.entity)
            }
            
        case .deleteItemSwipeAction:
            // アラート表示
            updateTargetState.alert = .createAlertStateWithCancel(
                .deleteDiaryItemConfirmAlert,
                firstButtonHandler:
                        .confirmDeleteItem(deleteItemId: id)
            )
            
        case .editItemSwipeAction:
            // アラート表示
            updateTargetState.alert = .createAlertStateWithCancel(
                .editDiaryItemConfirmAlert,
                firstButtonHandler: .confirmEditItem(targetId: id)
            )
        }
        
        return updateTargetState
    }
}
