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
        
        /// 画面表示
        case onAppear
        /// 画面非表示
        case onDisappear
        /// ダイアログ外の領域タップ
        case tappedOutsideArea
        /// 閉じるボタンタップ
        case tappedCloseButton
        /// フィルター種別の削除ボタンタップ
        case tappedFilterTypeDeleteButton(DiaryListFilterTarget)
        /// フィルター種別の項目削除ボタンタップ
        case tappedFilterItemDeleteButton(DiaryListFilterItem)
        /// フィルターメニューの項目タップ
        case tappedFilterMenuItem(DiaryListFilterItem)
        /// フィルターの更新を検知
        case receiveDidChangeFilterItems([DiaryListFilterItem])
    }
    
    @Dependency(\.diaryListFilterApi) var diaryListFilterApi
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            
            switch action {
                
            case .onAppear:
                return .concatenate(
                    .run { send in
                        
                        let result = try await diaryListFilterApi.fetchFilterList()
                        await send(.receiveDidChangeFilterItems(result))
                    },
                    .publisher {
                        
                        // フィルターテーブルの変更監視開始
                        diaryListFilterApi.getFilterListObserver().map { .receiveDidChangeFilterItems($0) }
                    }.cancellable(id: FilterObserveCancellable())
                )
                
            case .onDisappear:
                // 監視解除
                return .cancel(id: FilterObserveCancellable())
                
            case .tappedOutsideArea:
                return .run { send in
                    
                    await dismiss()
                }
                
            case .tappedCloseButton:
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
                
            case .tappedFilterItemDeleteButton(let item):
                return .run { _ in
                    
                    guard await diaryListFilterApi.deleteFilters([item]) else {
                        
                        print("did fail delete filter(item: \(item)).")
                        return
                    }
                }
                
            case .tappedFilterMenuItem(let item):
                return .run { _ in
                    
                    guard await diaryListFilterApi.addFilter(item) else {
                        
                        print("did fail add filter(item: \(item)).")
                        return
                    }
                }
                
            case .receiveDidChangeFilterItems(let currentFilters):
                state.currentFilters = IdentifiedArray(uniqueElements: currentFilters)
                return .none
            }
        }
    }
}
