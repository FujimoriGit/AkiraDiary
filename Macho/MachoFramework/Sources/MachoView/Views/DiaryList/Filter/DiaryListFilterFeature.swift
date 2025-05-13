//
//  DiaryListFilterFeature.swift
//
//
//  Created by 佐藤汰一 on 2024/07/28.
//

@preconcurrency import Combine
import ComposableArchitecture
import Foundation
import MachoCore

@Reducer
struct DiaryListFilterFeature: PopUpableContentFeature {
    
    // フィルターテーブル監視のCancellable
    struct FilterObserveCancellable: Hashable {}
    
    @ObservableState
    struct State: Equatable, Sendable {
        
        var viewState = ViewState()
        
        @ObservationStateIgnored var currentFilters: IdentifiedArrayOf<DiaryListFilterItem> {
            
            get { viewState.currentFilters }
            set { viewState.currentFilters = newValue }
        }
        
        @ObservationStateIgnored var selectableFilterValues: [DiaryListFilterItem] {
            
            get { viewState.selectableFilterValues }
            set { viewState.selectableFilterValues = newValue }
        }
        
        struct ViewState: Equatable, Sendable {
            
            /// フィルターリスト
            var currentFilters = IdentifiedArrayOf<DiaryListFilterItem>()
            /// 選択可能なフィルターの値
            var selectableFilterValues: [DiaryListFilterItem] = []
        }
    }
    
    enum Action: Equatable, PopUpableContentAction {
        
        // MARK: Event Action
        
        /// 画面表示
        case onAppear
        /// 閉じるボタンタップ
        case tappedCloseButton
        /// フィルター種別の削除ボタンタップ
        case tappedFilterTypeDeleteButton(target: DiaryListFilterTarget)
        /// フィルター種別の項目削除ボタンタップ
        case tappedFilterItemDeleteButton(filter: DiaryListFilterItem)
        /// フィルターメニューの項目タップ
        case tappedFilterMenuItem(filter: DiaryListFilterItem)
        /// 画面非表示前
        case willDismiss
        
        // MARK: Effect Action
        
        /// フィルターの更新を検知
        case receiveDidChangeFilterItems([DiaryListFilterItem])
        /// 選択可能なフィルターの値取得完了
        case receiveFetchSelectableFilterRes([DiaryListFilterItem])
        
        // MARK: Delegate Action
        
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            
            case confirmedFilter([DiaryListFilterItem])
        }
        
        // MARK: Publisher Action
        
        /// フィルターの監視処理開始
        case startObserve(PublisherEvent)
        
        @CasePathable
        enum PublisherEvent: Equatable {
            
            case observeFilter(AnyPublisher<[DiaryListFilterItem], Never>)
            
            static func == (lhs: DiaryListFilterFeature.Action.PublisherEvent,
                            rhs: DiaryListFilterFeature.Action.PublisherEvent) -> Bool {
                
                return lhs.is(\.observeFilter) == rhs.is(\.observeFilter)
            }
        }
        
        static var willDismissAction: Self {
            
            return .willDismiss
        }
    }
    
    @Dependency(\.diaryListFilterClient) var diaryListFilterApi
    @Dependency(\.trainingTypeClient) var trainingTypeApi
    @Dependency(\.trainingTagClient) var trainingTagApi
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            
            switch action {
                
            case .onAppear:
                logger.info("onAppear")
                return initialLoadFilterInfo()
                
            case .tappedCloseButton:
                return callDismiss()
                
            case .tappedFilterTypeDeleteButton(let type):
                logger.info("tappedFilterTypeDeleteButton(type: \(type))")
                return deleteFilterType(currentFilters: state.currentFilters, type: type)
                
            case .tappedFilterItemDeleteButton(let filter):
                logger.info("tappedFilterItemDeleteButton(filter: \(filter)).")
                return deleteFilterItem(currentFilters: state.currentFilters,
                                        type: filter.target,
                                        value: filter.value)
                
            case .tappedFilterMenuItem(let filter):
                logger.info("tappedFilterMenuItem(filter: \(filter))")
                return .run { [state] _ in
                    
                    await addFilter(currentFilters: state.currentFilters, targetFilter: filter)
                }
                
            case .willDismiss:
                logger.info("willDismiss")
                return .concatenate(
                    .cancel(id: FilterObserveCancellable()),
                    .run { [filters = state.currentFilters.elements] send in
                        
                        await send(.delegate(.confirmedFilter(filters)))
                    }
                )
                
            case .receiveDidChangeFilterItems(let currentFilters):
                logger.info("receiveDidChangeFilterItems(currentFilters: \(currentFilters))")
                state.currentFilters = IdentifiedArray(uniqueElements: currentFilters)
                return .none
                
            case .receiveFetchSelectableFilterRes(let selectableFilterValues):
                logger.info("receiveFetchSelectableFilterRes(selectableFilterValues: \(selectableFilterValues))")
                state.selectableFilterValues = selectableFilterValues
                return .none
                
            case .startObserve(.observeFilter(let publisher)):
                logger.info("startFilterItemsObserver(publisher: \(publisher))")
                return observeFilter(publisher)
                
            case .delegate, .startObserve:
                return .none
            }
        }
    }
}

private extension DiaryListFilterFeature {
    
    func initialLoadFilterInfo() -> Effect<DiaryListFilterFeature.Action> {
        
        return .run { send in
            
            await send(.receiveFetchSelectableFilterRes(await fetchSelectableFilterValues()))
            
            let resultPublisher = await diaryListFilterApi.getFilterListObserver()?
                .receive(on: DispatchQueue.main)
                .map { output in
                    
                    return DiaryListFilterDataConverter.convertToDiaryFilterItemList(output)
                }
                .eraseToAnyPublisher() ?? PassthroughSubject().eraseToAnyPublisher()
            
            await send(.startObserve(.observeFilter(resultPublisher)))
        }
    }
    
    func observeFilter(_ publisher: AnyPublisher<[DiaryListFilterItem], Never>) -> EffectOf<Self> {
        
        return .publisher {
            
            publisher.map { .receiveDidChangeFilterItems($0) }
        }
        .cancellable(id: FilterObserveCancellable())
    }
    
    func deleteFilterType(currentFilters: IdentifiedArrayOf<DiaryListFilterItem>,
                          type: DiaryListFilterTarget) -> Effect<DiaryListFilterFeature.Action> {
        
        return .run { _ in
            
            let entities = DiaryListFilterDataConverter
                .convertToDiaryListFilterDataList(currentFilters.elements.filter { $0.target == type })
            guard await diaryListFilterApi.deleteFilters(entities) else {
                
                logger.error("did fail delete filter(target: \(type)).")
                return
            }
        }
    }
    
    func deleteFilterItem(currentFilters: IdentifiedArrayOf<DiaryListFilterItem>,
                          type: DiaryListFilterTarget,
                          value: String) -> Effect<DiaryListFilterFeature.Action> {
        
        return .run { _ in
            
            guard let deleteItem = currentFilters
                .first(where: { $0.target == type && $0.value == value }),
                  await diaryListFilterApi.deleteFilters([DiaryListFilterData(deleteItem)]) else {
                
                logger.error("did fail delete filter(target: \(type), value: \(value)).")
                return
            }
        }
    }
    
    /// フィルターの追加もしくはすでに保存しているフィルターの更新を行う
    func addFilter(currentFilters: IdentifiedArrayOf<DiaryListFilterItem>,
                   targetFilter: DiaryListFilterItem) async {
        
        // すでに同じフィルターが登録されている場合は、フィルターの追加処理は行わない
        if currentFilters.contains(where: { $0 == targetFilter }) {
            
            logger.debug("already exits same filter(\(targetFilter)).")
            return
        }
        
        guard await diaryListFilterApi.addFilter(DiaryListFilterData(targetFilter)) else {
            
            logger.error("did fail add filter(\(targetFilter)).")
            return
        }
        
        logger.debug("added filter(\(targetFilter)).")
    }
    
    /// アプリに登録しているトレーニング種目を取得する
    func fetchSelectableFilterValues() async -> [DiaryListFilterItem] {
                
        // トレーニング実績のフィルター値を追加
        let trainingAchievementList = TrainingAchievement.allCases.map {
            
            return DiaryListFilterItem(target: .achievement,
                                       filterItemId: $0.targetId,
                                       value: $0.title)
        }
        
        // トレーニング種目のフィルター値を追加
        let trainingTypeList = await trainingTypeApi.fetchAllType().map {
            
            return DiaryListFilterItem(target: .trainingType, filterItemId: $0.id, value: $0.name)
        }
        
        let trainingTagList = await trainingTagApi.fetchAll().map {
            
            return DiaryListFilterItem(target: .tag, filterItemId: $0.id, value: $0.tagName)
        }
        
        return trainingAchievementList + trainingTypeList + trainingTagList
    }
    
    /// フィルター画面終了時の終了時の処理
    func callDismiss() -> Effect<DiaryListFilterFeature.Action> {
        
        return .run { await $0(.willDismiss) }
    }
}
