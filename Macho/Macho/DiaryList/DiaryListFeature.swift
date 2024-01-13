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
        
        var diaries = IdentifiedArrayOf<DiaryListItemFeature.State>()
    }
    
    enum Action: Sendable {
        
        /// 日記一覧のリスト
//        case diaries(id: DiaryListItemFeature.State.ID, action: DiaryListItemFeature.Action)
        case diaries(IdentifiedActionOf<DiaryListItemFeature>)
        /// フィルターボタン押下時のアクション
        case tappedFilterButton
        /// グラフボタン押下時のアクション
        case tappedGraphButton
        /// 新規アイテム追加ボタン押下時のアクション
        case tappedCreateNewDiaryButton
        /// 日記一覧の各アイテム押下時のアクション
        case tappedDiaryItem(item: DiaryListItemFeature.State)
        /// 日記一覧リストのPull To Refresh時のアクション
        case refreshList
    }
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            
            switch action {
                
            case .diaries:
                return .none
                
            case .tappedFilterButton:
                print("--------------------------")
                print("tapped filter button")
                print("\(state.diaries.map { $0.title + ": " + $0.id.uuidString + "\n" })")
                print("--------------------------")
                state.diaries.append(.init(title: "filter", message: "test", date: Date(), isWin: true))
                return .none
                
            case .tappedGraphButton:
                print("--------------------------")
                print("tapped graph button")
                print("\(state.diaries.map { $0.title + ": " + $0.id.uuidString + "\n" })")
                print("--------------------------")
                state.diaries.append(.init(title: "graph", message: "test", date: Date(), isWin: true))
                return .none
                
            case .tappedCreateNewDiaryButton:
                print("--------------------------")
                print("tapped create new diary button")
                print("\(state.diaries.map { $0.title + ": " + $0.id.uuidString + "\n" })")
                print("--------------------------")
                state.diaries.append(.init(title: "create", message: "test", date: Date(), isWin: true))
                return .none
                
            case .tappedDiaryItem(let item):
                print("--------------------------")
                print("tapped diary item")
                print(item)
                print("--------------------------")
                return .none
                
            case .refreshList:
                return .none
            }
        }
        .forEach(\.diaries, action: \.diaries) {
            DiaryListItemFeature()
        }
//        .forEach(\.diaries, action: /Action.diaries(id:action:)) {
//            DiaryListItemFeature()
//        }
//        .forEach(\.diaries, action: Action.diaries) {
//            DiaryListItemFeature()
//        }
        
    }
}
