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
        /// 日記リスト画面で監視したいプロパティを持つState
        var viewState = ViewState()
        
        struct ViewState: Equatable {
            
            /// スクロール中かどうか
            var isScrolling = false
            /// 日記リストのスクロールエリアのY軸のoffset
            var isBounced = false
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
        /// 日記一覧の各アイテム押下時のアクション
        case tappedDiaryItem(item: DiaryListItemFeature.State)
        /// 日記一覧リストのPull To Refresh時のアクション
        case pullToRefreshListAtBottom
    }
    
    var body: some ReducerOf<Self> {
        
        Scope(state: \.trackableList, action: \.trackableList) {
            TrackableListFeature()
        }
        .onChange(of: \.trackableList) { _, trackableListState in
            Reduce { state, _ in
                print("onChange trackableList state: \(trackableListState)")
                state.viewState.isScrolling = trackableListState.isScrolling
                state.viewState.isBounced = trackableListState.isBouncedAtBottom
                return .none
            }
        }
        Reduce { state, action in
            
            switch action {
                
            case .diaries, .trackableList:
                return .none
                
            case .tappedFilterButton:
//                print("--------------------------")
//                print("tapped filter button")
//                print("\(state.diaries.map { $0.title + ": " + $0.id.uuidString + "\n" })")
//                print("--------------------------")
                state.diaries.append(.init(title: "filter", message: "test", date: Date(), isWin: true))
                return .none
                
            case .tappedGraphButton:
//                print("--------------------------")
//                print("tapped graph button")
//                print("\(state.diaries.map { $0.title + ": " + $0.id.uuidString + "\n" })")
//                print("--------------------------")
                state.diaries.append(.init(title: "graph", message: "test", date: Date(), isWin: true))
                return .none
                
            case .tappedCreateNewDiaryButton:
//                print("--------------------------")
//                print("tapped create new diary button")
//                print("\(state.diaries.map { $0.title + ": " + $0.id.uuidString + "\n" })")
//                print("--------------------------")
                state.diaries.append(.init(title: "create", message: "test", date: Date(), isWin: true))
                return .none
                
            case .tappedDiaryItem(let item):
//                print("--------------------------")
//                print("tapped diary item")
//                print(item)
//                print("--------------------------")
                return .none
                
            case .pullToRefreshListAtBottom:
                print("refresh diary")
                return .run { _ in
                    // TODO: Realmから一覧を取得する処理
                }
            }
        }
        .forEach(\.diaries, action: \.diaries) {
            DiaryListItemFeature()
        }
    }
}
