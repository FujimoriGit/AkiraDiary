//
//  DiaryListFilterFeature.swift
//
//
//  Created by 佐藤汰一 on 2024/07/28.
//

import ComposableArchitecture

@Reducer
struct DiaryListFilterFeature {
    
    struct State: Equatable, Sendable {
        
        var currentFilters = IdentifiedArrayOf<DiaryListFilterItem>()
    }
    
    enum Action: Equatable {
        
        /// 画面表示
        case onAppear
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
            return .none
        }
    }
}
