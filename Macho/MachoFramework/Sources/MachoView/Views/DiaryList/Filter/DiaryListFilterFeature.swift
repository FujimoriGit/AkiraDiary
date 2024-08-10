//
//  DiaryListFilterFeature.swift
//
//
//  Created by 佐藤汰一 on 2024/07/28.
//

import ComposableArchitecture

@Reducer
struct DiaryListFilterFeature {
    
    // フィルターテーブル監視のCancellable
    struct FilterObserveCancellable: Hashable {}
    
    struct State: Equatable, Sendable {
        
        /// フィルターリスト
        var currentFilters = IdentifiedArrayOf<DiaryListFilterItem>()
    }
    
    enum Action: Equatable {
        
        // MARK: Event Action
        
        /// 画面表示
        case onAppear
        /// 画面非表示
        case onDisappear
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
    }
    
    @Dependency(\.diaryListFilterApi) var diaryListFilterApi
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.uuid) var uuid
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            
            switch action {
                
            case .onAppear:
                print("onAppear.")
                return .concatenate(
                    .run { send in
                        
                        let result = await diaryListFilterApi.fetchFilterList()
                        await send(.receiveDidChangeFilterItems(result))
                    },
                    .publisher {
                        
                        // フィルターテーブルの変更監視開始
                        return diaryListFilterApi.getFilterListObserver().map {
                            
                            .receiveDidChangeFilterItems($0) }
                    }.cancellable(id: FilterObserveCancellable())
                )
                
            case .onDisappear:
                print("onDisappear.")
                // 監視解除
                return .cancel(id: FilterObserveCancellable())
                
            case .tappedOutsideArea:
                print("tappedOutsideArea.")
                return .run { send in
                    
                    await dismiss()
                }
                
            case .tappedCloseButton:
                print("tappedCloseButton.")
                return .run { _ in
                    
                    await dismiss()
                }
                
            case .tappedFilterTypeDeleteButton(let type):
                return .run { [state] _ in
                    
                    guard await diaryListFilterApi.deleteFilters(state.currentFilters.filter { $0.target == type }) else {
                        
                        print("did fail delete filter(target: \(type)).")
                        return
                    }
                }
                
            case .tappedFilterItemDeleteButton(let target, let value):
                return .run { [state] _ in
                    
                    guard let deleteItem = state.currentFilters.first(where: { $0.target == target && $0.value == value }),
                          await diaryListFilterApi.deleteFilters([deleteItem]) else {
                        
                        print("did fail delete filter(target: \(target), value: \(value)).")
                        return
                    }
                }
                
            case .tappedFilterMenuItem(let target, let value):
                return .run { [state] _ in
                    
                    await addFilter(currentFilters: state.currentFilters, target: target, value: value)
                }
                
            case .receiveDidChangeFilterItems(let currentFilters):
                state.currentFilters = IdentifiedArray(uniqueElements: currentFilters)
                return .none
            }
        }
    }
}

private extension DiaryListFilterFeature {
    
    /// フィルターの追加もしくはすでに保存しているフィルターの更新を行う
    func addFilter(currentFilters: IdentifiedArrayOf<DiaryListFilterItem>, target: DiaryListFilterTarget, value: String) async {
        
        let id = currentFilters.first { $0.target == target }?.id
        if target.isMultiSelectFilter || id == nil {
            
            // 複数選択可能な場合または、まだ登録されていないフィルター種別の場合は、新規のフィルターとしてDBに保存する
            guard await diaryListFilterApi.addFilter(DiaryListFilterItem(id: uuid(), target: target, value: value)) else {
                
                print("did fail add filter(target: \(target), value: \(value)).")
                return
            }
        }
        else {
            
            // それ以外の場合は、すでに登録されている同じフィルター種別の値を更新する
            guard let id,
                  await diaryListFilterApi.updateFilter(DiaryListFilterItem(id: id, target: target, value: value)) else {
                
                print("did fail update filter(target: \(target), value: \(value)).")
                return
            }
        }
    }
}
