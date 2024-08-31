//
//  DiaryListFilterFeature.swift
//
//
//  Created by 佐藤汰一 on 2024/07/28.
//

import ComposableArchitecture
import Foundation

@Reducer
struct DiaryListFilterFeature {
    
    // フィルターテーブル監視のCancellable
    struct FilterObserveCancellable: Hashable {}
    
    struct State: Equatable, Sendable {
        
        var viewState = ViewState()
        var currentFilters: IdentifiedArrayOf<DiaryListFilterItem> {
            
            get { viewState.currentFilters }
            set { viewState.currentFilters = newValue }
        }
        
        var selectableFilterValues: [DiaryListFilterTarget: [String]] {
            
            get { viewState.selectableFilterValues }
            set { viewState.selectableFilterValues = newValue }
        }
        
        struct ViewState: Equatable, Sendable {
            
            /// フィルターリスト
            var currentFilters = IdentifiedArrayOf<DiaryListFilterItem>()
            /// 選択可能なフィルターの値
            var selectableFilterValues: [DiaryListFilterTarget: [String]] = [:]
        }
    }
    
    enum Action: Equatable {
        
        // MARK: Event Action
        
        /// 画面表示
        case onAppear
        /// ダイアログ外の領域タップ
        case tappedOutsideArea
        /// 閉じるボタンタップ
        case tappedCloseButton
        /// フィルター種別の削除ボタンタップ
        case tappedFilterTypeDeleteButton(target: DiaryListFilterTarget)
        /// フィルター種別の項目削除ボタンタップ
        case tappedFilterItemDeleteButton(target: DiaryListFilterTarget, value: String)
        /// フィルターメニューの項目タップ
        case tappedFilterMenuItem(target: DiaryListFilterTarget, value: String)
        
        // MARK: Effect Action
        
        /// フィルターの更新を検知
        case receiveDidChangeFilterItems([DiaryListFilterItem])
        /// 選択可能なフィルターの値取得完了
        case receiveFetchSelectableFilterRes([DiaryListFilterTarget: [String]])
    }
    
    @Dependency(\.diaryListFilterApi) var diaryListFilterApi
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.uuid) var uuid
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            
            switch action {
                
            case .onAppear:
                logger.info("onAppear")
                return initialLoadFilterInfo()
                
            case .tappedOutsideArea:
                logger.info("tappedOutsideArea")
                return callDismiss()
                
            case .tappedCloseButton:
                logger.info("tappedCloseButton")
                return callDismiss()
                
            case .tappedFilterTypeDeleteButton(let type):
                logger.info("tappedFilterTypeDeleteButton(type: \(type))")
                return deleteFilterType(currentFilters: state.currentFilters, type: type)
                
            case .tappedFilterItemDeleteButton(let target, let value):
                logger.info("tappedFilterItemDeleteButton(target: \(target), value: \(value)).")
                return deleteFilterItem(currentFilters: state.currentFilters,
                                        type: target,
                                        value: value)
                
            case .tappedFilterMenuItem(let target, let value):
                logger.info("tappedFilterMenuItem(target: \(target), value: \(value))")
                return .run { [state] _ in
                    
                    await addFilter(currentFilters: state.currentFilters, target: target, value: value)
                }
                
            case .receiveDidChangeFilterItems(let currentFilters):
                logger.info("receiveDidChangeFilterItems(currentFilters: \(currentFilters))")
                state.currentFilters = IdentifiedArray(uniqueElements: currentFilters)
                return .none
                
            case .receiveFetchSelectableFilterRes(let selectableFilterValues):
                logger.info("receiveFetchSelectableFilterValuesResponse(selectableFilterValues: \(selectableFilterValues))")
                state.selectableFilterValues = selectableFilterValues
                return .none
            }
        }
    }
}

private extension DiaryListFilterFeature {
    
    func initialLoadFilterInfo() -> Effect<DiaryListFilterFeature.Action> {
        
        return .concatenate(
            .run { send in
                
                await send(.receiveFetchSelectableFilterRes(await fetchSelectableFilterValues()))
            },
            .run { send in
                
                let result = await diaryListFilterApi.fetchFilterList()
                await send(.receiveDidChangeFilterItems(result))
            },
            .publisher {
                
                return diaryListFilterApi.getFilterListObserver()
                    .receive(on: DispatchQueue.main)
                    .map { .receiveDidChangeFilterItems($0) }
            }.cancellable(id: FilterObserveCancellable())
        )
    }
    
    func deleteFilterType(currentFilters: IdentifiedArrayOf<DiaryListFilterItem>,
                          type: DiaryListFilterTarget) -> Effect<DiaryListFilterFeature.Action> {
        
        return .run { _ in
            
            guard await diaryListFilterApi.deleteFilters(currentFilters.filter { $0.target == type }) else {
                
                logger.error("did fail delete filter(target: \(type)).")
                return
            }
        }
    }
    
    func deleteFilterItem(currentFilters: IdentifiedArrayOf<DiaryListFilterItem>,
                          type: DiaryListFilterTarget,
                          value: String) -> Effect<DiaryListFilterFeature.Action> {
        
        return .run { _ in
            
            guard let deleteItem = currentFilters.first(where: { $0.target == type && $0.value == value }),
                  await diaryListFilterApi.deleteFilters([deleteItem]) else {
                
                logger.error("did fail delete filter(target: \(type), value: \(value)).")
                return
            }
        }
    }
    
    /// フィルターの追加もしくはすでに保存しているフィルターの更新を行う
    func addFilter(currentFilters: IdentifiedArrayOf<DiaryListFilterItem>,
                   target: DiaryListFilterTarget,
                   value: String) async {
        
        let sameTargetId = currentFilters.first { $0.target == target }?.id
        if sameTargetId == nil || target.isMultiSelectFilter {
            
            // すでに同じフィルターが登録されている場合は、フィルターの追加処理は行わない
            if currentFilters.contains(where: { $0.target == target && $0.value == value }) {
                
                logger.debug("already exits same filter(target: \(target), value: \(value)).")
                return
            }
            
            // 複数選択可能な場合または、まだ登録されていないフィルター種別の場合は、
            // 新規のフィルターとしてDBに保存する
            guard await diaryListFilterApi.addFilter(DiaryListFilterItem(id: uuid(),
                                                                         target: target,
                                                                         value: value)) else {
                
                logger.error("did fail add filter(target: \(target), value: \(value)).")
                return
            }
            
            logger.debug("added filter(target: \(target), value: \(value)).")
        }
        else {
            
            // それ以外の場合は、すでに登録されている同じフィルター種別の値を更新する
            guard let sameTargetId,
                  await diaryListFilterApi.updateFilter(DiaryListFilterItem(id: sameTargetId,
                                                                            target: target,
                                                                            value: value)) else {
                
                logger.error("did fail update filter(target: \(target), value: \(value)).")
                return
            }
            
            logger.debug("updated filter(target: \(target), value: \(value)).")
        }
    }
    
    /// アプリに登録しているトレーニング種目を取得する
    func fetchSelectableFilterValues() async -> [DiaryListFilterTarget: [String]] {
        
        var resultDic: [DiaryListFilterTarget: [String]] = [:]
        
        // トレーニング実績のフィルター値を追加
        resultDic.updateValue(TrainingAchievement.allCases.map(\.title), forKey: .achievement)
        
        // トレーニング種目のフィルター値を追加
        // TODO: 藤森氏の日記作成画面で作るトレーニング種目TBLから取得する想定
        resultDic.updateValue(["腹筋", "ダンベルプレス"], forKey: .trainingType)
        
        return resultDic
    }
    
    /// フィルター画面終了時の終了時の処理
    func callDismiss() -> Effect<DiaryListFilterFeature.Action> {
        
        return Effect.concatenate(
            .cancel(id: FilterObserveCancellable()),
            .run { _ in await self.dismiss() }
        )
    }
}
