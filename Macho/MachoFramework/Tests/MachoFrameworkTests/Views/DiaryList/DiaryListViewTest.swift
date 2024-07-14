//
//  DiaryListViewTest.swift
//
//
//  Created by 佐藤汰一 on 2024/06/01.
//

import ComposableArchitecture
import XCTest

@testable import MachoView

final class DiaryListViewTests: XCTestCase {
    
    // アラートの表示確認
    @MainActor
    func testAlert() async {
        
        let diariesState: IdentifiedArray<UUID, DiaryListItemFeature.State> = [
            DiaryListItemFeature.State(title: "test1", message: "", date: Date(), isWin: true),
         ]
        
        let store = TestStore(
            initialState: DiaryListFeature.State(diaries: diariesState)) {
            DiaryListFeature()
        }
                
        // 削除確認アラートの表示
        await store.send(.diaries(.element(id: diariesState[0].id, action: .deleteItemSwipeAction))) {
            
            $0.alert = AlertState.createAlertStateWithCancel(.deleteDiaryItemConfirmAlert,
                                                             firstButtonHandler: .confirmDeleteItem(deleteItemId: diariesState[0].id))
        }
        
        // 編集確認アラートの表示
        await store.send(.diaries(.element(id: diariesState[0].id, action: .editItemSwipeAction))) {
            
            $0.alert = AlertState.createAlertStateWithCancel(.editDiaryItemConfirmAlert,
                                                             firstButtonHandler: .confirmEditItem(targetId: diariesState[0].id))
        }
        
        // 日記リスト取得失敗アラートの表示
        await store.send(.failedLoadDiaryItems) {
            
            $0.alert = AlertState.createAlertState(.failedLoadDiaryItemsAlert, firstButtonHandler: .failedLoadDiaryItems)
        }
    }
    
    // 日記リスト画面をスクロールした時のケース
    @MainActor
    func testScrollBouncedDiaryList() async {
        
        let expectedAddedItem = DiaryListItemFeature.State(title: "test2", message: "test message", date: Date(), isWin: false)
        
        // スクロール画面の表示サイズの高さが800px、スクロールできるサイズの高さが1000pxの状態
        let trackableListState = TrackableListFeature.State(offset: 0,
                                                            containerSize: CGSize(width: 400, height: 800),
                                                            contentSize: CGSize(width: 400, height: 1000))
        
        let store = TestStore(
            initialState: DiaryListFeature.State(diaries: [
                DiaryListItemFeature.State(title: "test1", message: "", date: Date(), isWin: true)
            ], trackableList: trackableListState), reducer: { DiaryListFeature() }) {
                
                $0.diaryListFetchApi = DiaryListItemClient(fetch: { _, _ in
                    
                    return [expectedAddedItem]
                }, deleteItem: { _ in })
            }
        
        // 300pxスクロールして下にバウンスが発生
        await store.send(.trackableList(TrackableListFeature.Action.onScroll(offset: -300))) {
            
            // リスト画面のoffset更新
            $0.trackableList.offset = -300
            // バウンス検知
            $0.viewState.isBounced = true
            // スクロール中
            $0.viewState.isScrolling = true
            // バウンス検知で日記リストのロード処理開始
            $0.viewState.isLoadingDiaries = true
        }
        
        // 日記項目のロードを行う
        await store.receive(.receiveLoadDiaryItems(items: [expectedAddedItem])) {
            
            // 日記リストのロード処理終了
            $0.viewState.isLoadingDiaries = false
            // 日記リストの更新
            $0.diaries.append(expectedAddedItem)
        }
        
        // 上にスクロールして一番上の画面に戻る
        await store.send(.trackableList(TrackableListFeature.Action.onScroll(offset: 0))) {
            
            // リスト画面のoffset更新
            $0.trackableList.offset = 0
            // バウンスしていない
            $0.viewState.isBounced = false
            // スクロール中でない
            $0.viewState.isScrolling = false
        }
    }
    
    // 日記リスト初回画面表示時に日記リスト取得成功した時のケース
    @MainActor
    func testOnAppearView() async {
        
        let expectedItem = DiaryListItemFeature.State(title: "test", message: "test message", date: Date(), isWin: true)
        
        let store = TestStore(initialState: DiaryListFeature.State(), reducer: { DiaryListFeature() }) {
            
            $0.diaryListFetchApi = DiaryListItemClient(fetch: { _, _ in
                
                return [expectedItem]
            }, deleteItem: { _ in })
        }
        
        // 日記リスト画面表示時の動作
        await store.send(.onAppearView) {
            
            // 日記リスト取得処理開始
            $0.viewState.isLoadingDiaries = true
        }
        
        // 日記リスト取得イベント受信
        await store.receive(.receiveLoadDiaryItems(items: [expectedItem])) {
            
            // 日記リスト更新
            $0.diaries = [expectedItem]
            // 日記リスト取得処理終了
            $0.viewState.isLoadingDiaries = false
        }
    }
    
    // 日記リスト初回画面表示時に日記リスト取得失敗した時のケース
    @MainActor
    func testOnAppearViewWithFailFetchItems() async {
        
        let store = TestStore(initialState: DiaryListFeature.State(), reducer: { DiaryListFeature() }) {
            
            $0.diaryListFetchApi = DiaryListItemClient(fetch: { _, _ in
                
                throw NSError()
            }, deleteItem: { _ in })
        }
        
        // 日記リスト画面表示時の動作
        await store.send(.onAppearView) {
            
            // 日記リスト取得処理開始
            $0.viewState.isLoadingDiaries = true
        }
        
        // 日記リスト取得失敗イベント受信
        await store.receive(.failedLoadDiaryItems) {
            
            // 日記リスト取得処理終了
            $0.viewState.isLoadingDiaries = false
            // 日記リスト取得失敗アラート表示
            $0.alert = AlertState.createAlertState(.failedLoadDiaryItemsAlert, firstButtonHandler: .failedLoadDiaryItems)
        }
    }
    
    // 日記リストを保持している状態で画面表示時した時のケース
    @MainActor
    func testOnAppearViewWithAlreadyHasItems() async {
        
        let diariesState: IdentifiedArray<UUID, DiaryListItemFeature.State> = [
            DiaryListItemFeature.State(title: "test1", message: "", date: Date(), isWin: true),
         ]
                
        let store = TestStore(initialState: DiaryListFeature.State(diaries: diariesState),
                              reducer: { DiaryListFeature() }) {
            
            $0.diaryListFetchApi = DiaryListItemClient(fetch: { _, _ in
                
                return [DiaryListItemFeature.State(title: "test2", message: "", date: Date(), isWin: false)]
            }, deleteItem: { _ in })
        }
        
        // 日記リストが存在する時の画面表示時の動作
        await store.send(.onAppearView)
    }
    
    // 日記リストをタップした時のケース
    @MainActor
    func testTappedDiaryItem() async {
        
        let diariesState: IdentifiedArray<UUID, DiaryListItemFeature.State> = [
            DiaryListItemFeature.State(title: "test1", message: "", date: Date(), isWin: true),
         ]
        
        let store = TestStore(
            initialState: DiaryListFeature.State(diaries: diariesState)) {
                
            DiaryListFeature()
        }
        
        // TODO: タップ後の画面遷移処理はまだ実装できていないので、実装後にテストの期待値を実装する
        // 日記リストのセルタップ時の動作
        await store.send(.diaries(.element(id: diariesState[0].id, action: .tappedDiaryItem))) {
            
            // 編集画面をナビゲーションスタックに追加
            $0.path.append(.detailScreen(.init()))
        }
    }
    
    // 日記項目削除確認アラートで削除を選択した時のケース
    @MainActor
    func testTappedDeleteItem() async {
        
        let diariesState: IdentifiedArray<UUID, DiaryListItemFeature.State> = [
            DiaryListItemFeature.State(title: "test1", message: "", date: Date(), isWin: true),
         ]
        
        let store = TestStore(
            initialState: DiaryListFeature.State(diaries: diariesState)) {
                
            DiaryListFeature()
        }
        
        // 削除確認アラートの表示
        await store.send(.diaries(.element(id: diariesState[0].id, action: .deleteItemSwipeAction))) {
            
            $0.alert = AlertState.createAlertStateWithCancel(.deleteDiaryItemConfirmAlert,
                                                             firstButtonHandler: .confirmDeleteItem(deleteItemId: diariesState[0].id))
        }
        
        // 日記項目削除確認アラートで削除を選択した時
        await store.send(.alert(.presented(.confirmDeleteItem(deleteItemId: diariesState[0].id)))) {
            
            // アラート削除
            $0.alert = nil
        }
        
        await store.receive(.deletedDiaryItem(id: diariesState[0].id)) {
            
            // 選択した日記項目が日記リストから削除されていること
            $0.diaries.remove(id: diariesState[0].id)
        }
    }
    
    // 日記項目編集確認アラートで編集を選択した時のケース
    @MainActor
    func testTappedEditItem() async {
        
        let diariesState: IdentifiedArray<UUID, DiaryListItemFeature.State> = [
            DiaryListItemFeature.State(title: "test1", message: "", date: Date(), isWin: true),
         ]
        
        let store = TestStore(
            initialState: DiaryListFeature.State(diaries: diariesState)) {
                
            DiaryListFeature()
        }
        
        // 編集確認アラートの表示
        await store.send(.diaries(.element(id: diariesState[0].id, action: .editItemSwipeAction))) {
            
            $0.alert = AlertState.createAlertStateWithCancel(.editDiaryItemConfirmAlert,
                                                             firstButtonHandler: .confirmEditItem(targetId: diariesState[0].id))
        }
        
        // TODO: 編集画面への遷移が未実装のため、実装後にテストの期待値を実装する
        // 日記項目編集確認アラートで編集を選択した時
        await store.send(.alert(.presented(.confirmEditItem(targetId: diariesState[0].id)))) {
            
            // アラート削除
            $0.alert = nil
            // 編集画面をナビゲーションスタックに追加
            $0.path.append(.editScreen(.init()))
        }
    }
    
    // 日記作成ボタンを押下した時のケース
    @MainActor
    func testTappedAddDiaryButton() async {
        
        let store = TestStore(
            initialState: DiaryListFeature.State()) {
                
            DiaryListFeature()
        }
        
        // TODO: 日記作成画面への遷移が未実装のため、実装後にテストの期待値を実装する
        // 日記作成ボタンを押下
        await store.send(.tappedCreateNewDiaryButton) {
            
            // 日記作成画面をナビゲーションスタックに追加
            $0.path.append(.createScreen(.init()))
        }
    }
    
    // グラフボタンを押下した時のケース
    @MainActor
    func testTappedGraphButton() async {
        
        let store = TestStore(
            initialState: DiaryListFeature.State()) {
                
            DiaryListFeature()
        }
        
        // TODO: グラフ画面への遷移が未実装のため、実装後にテストの期待値を実装する
        // グラフボタンを押下
        await store.send(.tappedGraphButton) {
            
            // グラフ画面をナビゲーションスタックに追加
            $0.path.append(.graphScreen(.init()))
        }
    }
}
