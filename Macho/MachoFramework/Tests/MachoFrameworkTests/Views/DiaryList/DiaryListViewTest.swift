//
//  DiaryListViewTest.swift
//
//
//  Created by 佐藤汰一 on 2024/06/01.
//

import ComposableArchitecture
import XCTest

@testable import MachoView
import Combine

final class DiaryListViewTests: XCTestCase {
    
    enum TestError: Error {
        
        case loadingError
    }
    
    // 日記リストItemのインスタンス生成時に使用するUUID
    private let firstUuid = UUID()
    private let secondUuid = UUID()
    private let thirdUuid = UUID()
    
    // アラートの表示確認
    @MainActor
    func testAlert() async {
        
        let diariesState: IdentifiedArray<UUID, DiaryListItemFeature.State> = [
            DiaryListItemFeature.State(title: "test1", message: "", date: Date(), isWin: true, trainingList: [], tagList: []),
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
        
        let firstDate = Date()
        guard let secondDate = Calendar.current.date(byAdding: .second, value: 1, to: firstDate),
              let thirdDate = Calendar.current.date(byAdding: .second, value: 1, to: secondDate) else {
            
            XCTFail("fail setup test param.")
            return
        }
        
        let expectedAddedItem = DiaryListItemFeature.State(id: thirdUuid,title: "test2", message: "test message", date: thirdDate, isWin: false, trainingList: [], tagList: [])
        
        let expectedLoadedDiaries = IdentifiedArray(uniqueElements: [
            expectedAddedItem,
            DiaryListItemFeature.State(id: secondUuid, title: "test3", message: "test message", date: secondDate, isWin: false, trainingList: [], tagList: []),
            DiaryListItemFeature.State(id: firstUuid, title: "test1", message: "", date: firstDate, isWin: true, trainingList: [], tagList: [])
        ])
        
        // スクロール画面の表示サイズの高さが800px、スクロールできるサイズの高さが1000pxの状態
        let trackableListState = TrackableListFeature.State(offset: 0,
                                                            listSizeInfo: .init(containerSize: CGSize(width: 400, height: 800),
                                                                                contentSize: CGSize(width: 400, height: 1000)))
        
        let viewState = DiaryListFeature.State.ViewState(hasDiaryItems: true)
        
        let store = TestStore(
            initialState: DiaryListFeature.State(diaries: [
                DiaryListItemFeature.State(id: firstUuid, title: "test1", message: "", date: firstDate, isWin: true, trainingList: [], tagList: []),
                DiaryListItemFeature.State(id: secondUuid, title: "test3", message: "test message", date: secondDate, isWin: false, trainingList: [], tagList: [])
            ], trackableList: trackableListState, viewState: viewState), reducer: { DiaryListFeature() }) {
                
                $0.diaryListFetchApi = DiaryListItemClient(fetch: { _, _ in
                    
                    return [expectedAddedItem]
                }, deleteItem: { _ in })
            }
        
        // 300pxスクロールして下にバウンスが発生
        await store.send(.trackableList(TrackableListFeature.Action.onScroll(offset: -300))) {
            
            // リスト画面のoffset更新
            $0.trackableList.offset = -300
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
            $0.diaries = expectedLoadedDiaries
        }
        
        // 上にスクロールして一番上の画面に戻る
        await store.send(.trackableList(TrackableListFeature.Action.onScroll(offset: 0))) {
            
            // リスト画面のoffset更新
            $0.trackableList.offset = 0
            // スクロール中でない
            $0.viewState.isScrolling = false
        }
    }
    
    // 日記リスト初回画面表示時に日記リスト取得成功した時のケース
    @MainActor
    func testOnAppearView() async {
        
        let expectedItem = DiaryListItemFeature.State(title: "test", message: "test message", date: Date(), isWin: false, trainingList: [], tagList: [])
        let receivedFilters = [DiaryListFilterItem(target: .achievement, filterItemId: UUID(), value: "達成していない")]
        
        let store = TestStore(initialState: DiaryListFeature.State(), reducer: { DiaryListFeature() }) {
            
            $0.diaryListFetchApi = DiaryListItemClient(fetch: { _, _ in
                
                return [expectedItem]
            }, deleteItem: { _ in })
            $0.diaryListFilterApi = DiaryListFilterClient.getFetchOnlyClientForTest(receivedFilters)
            $0.date = DateGenerator({ Date() })
        }
        
        // 日記リスト画面表示時の動作
        await store.send(.onAppearView) {
            
            // 日記リスト取得処理開始
            $0.viewState.isLoadingDiaries = true
        }
        
        // 日記リストのフィルター取得イベント受信
        await store.receive(.receiveLoadDiaryListFilter(filters: receivedFilters)) {
            
            $0.currentFilters = receivedFilters
        }
        
        // 日記リスト取得イベント受信
        await store.receive(.receiveLoadDiaryItems(items: [expectedItem])) {
            
            // 日記リスト更新
            $0.diaries = [expectedItem]
            // 日記リスト取得処理終了
            $0.viewState.isLoadingDiaries = false
            // 日記リストがあるかどうかのフラグ更新
            $0.viewState.hasDiaryItems = true
        }
        
        // 画面非表示
        await store.send(.onDisappearView)
    }
    
    // 日記リスト初回画面表示時に日記リスト取得失敗した時のケース
    @MainActor
    func testOnAppearViewWithFailFetchItems() async {
        
        let receivedFilters = [DiaryListFilterItem(target: .achievement, filterItemId: UUID(), value: "達成していない")]
        
        let store = TestStore(initialState: DiaryListFeature.State(), reducer: { DiaryListFeature() }) {
            
            $0.diaryListFetchApi = DiaryListItemClient(fetch: { _, _ in
                
                throw TestError.loadingError
            }, deleteItem: { _ in })
            $0.diaryListFilterApi = DiaryListFilterClient.getFetchOnlyClientForTest(receivedFilters)
            $0.date = DateGenerator({ Date() })
        }
        
        // 日記リスト画面表示時の動作
        await store.send(.onAppearView) {
            
            // 日記リスト取得処理開始
            $0.viewState.isLoadingDiaries = true
        }
        
        // 日記リストのフィルター取得イベント受信
        await store.receive(.receiveLoadDiaryListFilter(filters: receivedFilters)) {
            
            $0.currentFilters = receivedFilters
        }
        
        // 日記リスト取得失敗イベント受信
        await store.receive(.failedLoadDiaryItems) {
            
            // 日記リスト取得処理終了
            $0.viewState.isLoadingDiaries = false
            // 日記リスト取得失敗アラート表示
            $0.alert = AlertState.createAlertState(.failedLoadDiaryItemsAlert, firstButtonHandler: .failedLoadDiaryItems)
        }
        
        // 画面非表示
        await store.send(.onDisappearView)
    }
    
    // 日記リストを保持している状態で画面表示時した時のケース
    @MainActor
    func testOnAppearViewWithAlreadyHasItems() async {
        
        let achievementId = UUID(TrainingAchievement.notAchieved.rawValue)
        let absTrainingId = UUID()
        
        let firstDate = Date()
        guard let secondDate = Calendar.current.date(byAdding: .second, value: 1, to: firstDate),
              let thirdDate = Calendar.current.date(byAdding: .second, value: 1, to: secondDate) else {
            
            XCTFail("fail setup test param.")
            return
        }
        
        let expectedItem = DiaryListItemFeature.State(title: "test2", message: "test message", date: secondDate, isWin: false, trainingList: [absTrainingId], tagList: [])
        
        let expectedFilteredDiaries = IdentifiedArray(uniqueElements: [
            DiaryListItemFeature.State(id: thirdUuid, title: "test3", message: "", date: thirdDate, isWin: false, trainingList: [absTrainingId], tagList: []),
            DiaryListItemFeature.State(id: firstUuid, title: "test1", message: "", date: firstDate, isWin: false, trainingList: [absTrainingId], tagList: [])
        ])
        
        let expectedLoadedDiaries = IdentifiedArray(uniqueElements: [
            DiaryListItemFeature.State(id: thirdUuid, title: "test3", message: "", date: thirdDate, isWin: false, trainingList: [absTrainingId], tagList: []),
            expectedItem,
            DiaryListItemFeature.State(id: firstUuid, title: "test1", message: "", date: firstDate, isWin: false, trainingList: [absTrainingId], tagList: [])
        ])
        
        let diariesState: IdentifiedArray<UUID, DiaryListItemFeature.State> = [
            DiaryListItemFeature.State(id: firstUuid, title: "test1", message: "", date: firstDate, isWin: false, trainingList: [absTrainingId], tagList: []),
            DiaryListItemFeature.State(id: thirdUuid, title: "test3", message: "", date: thirdDate, isWin: false, trainingList: [absTrainingId], tagList: [])
         ]
        
        let receivedFilters = [
            DiaryListFilterItem(target: .achievement, filterItemId: achievementId, value: "達成していない"),
            DiaryListFilterItem(target: .trainingType, filterItemId: absTrainingId, value: "腹筋")
        ]
                
        let store = TestStore(initialState: DiaryListFeature.State(diaries: diariesState),
                              reducer: { DiaryListFeature() }) {
            
            $0.diaryListFetchApi = DiaryListItemClient(fetch: { _, _ in
                
                return [expectedItem]
            }, deleteItem: { _ in })
            $0.diaryListFilterApi = DiaryListFilterClient.getFetchOnlyClientForTest(receivedFilters)
            $0.date = DateGenerator({ Date() })
        }
        
        // 日記リスト画面表示時の動作
        await store.send(.onAppearView) {
            
            // 日記リスト取得処理開始
            $0.viewState.isLoadingDiaries = true
        }
        
        // 日記リストのフィルター取得イベント受信
        await store.receive(.receiveLoadDiaryListFilter(filters: receivedFilters)) {
            
            $0.currentFilters = receivedFilters
            $0.diaries = expectedFilteredDiaries
        }
        
        // 日記リスト取得イベント受信
        await store.receive(.receiveLoadDiaryItems(items: [expectedItem])) {
            
            // 日記リスト更新
            $0.diaries = expectedLoadedDiaries
            // 日記リスト取得処理終了
            $0.viewState.isLoadingDiaries = false
            // 日記リストがあるかどうかのフラグ更新
            $0.viewState.hasDiaryItems = true
        }
        
        // 画面非表示
        await store.send(.onDisappearView)
    }
    
    // フィルターにヒットする日記がないケース
    @MainActor
    func testOnAppearViewWithNoHitsFilter() async {
        
        let achievementId = UUID(TrainingAchievement.notAchieved.rawValue)
        let absTrainingId = UUID()
        let squatTrainingId = UUID()
        let plunkTrainingId = UUID()
        let benchPressTrainingId = UUID()
        let tagId = UUID()
                
        let receivedItem = [DiaryListItemFeature.State(title: "test1", message: "test message", date: Date(), isWin: true, trainingList: [], tagList: []),
                            DiaryListItemFeature.State(title: "test2", message: "test message", date: Date(), isWin: false, trainingList: [plunkTrainingId], tagList: []),
                            DiaryListItemFeature.State(title: "test3", message: "test message", date: Date(), isWin: false, trainingList: [benchPressTrainingId], tagList: [])]
        
        let receivedFilters = [
            DiaryListFilterItem(target: .achievement, filterItemId: achievementId, value: "達成していない"),
            DiaryListFilterItem(target: .trainingType, filterItemId: absTrainingId, value: "腹筋"),
            DiaryListFilterItem(target: .trainingType, filterItemId: squatTrainingId, value: "スクワット"),
            DiaryListFilterItem(target: .tag, filterItemId: tagId, value: "元気")
        ]
                
        let store = TestStore(initialState: DiaryListFeature.State(),
                              reducer: { DiaryListFeature() }) {
            
            $0.diaryListFetchApi = DiaryListItemClient(fetch: { _, _ in
                
                return receivedItem
            }, deleteItem: { _ in })
            $0.diaryListFilterApi = DiaryListFilterClient.getFetchOnlyClientForTest(receivedFilters)
            $0.date = DateGenerator({ Date() })
        }
        
        // 日記リスト画面表示時の動作
        await store.send(.onAppearView) {
            
            // 日記リスト取得処理開始
            $0.viewState.isLoadingDiaries = true
        }
        
        // 日記リストのフィルター取得イベント受信
        await store.receive(.receiveLoadDiaryListFilter(filters: receivedFilters)) {
            
            $0.currentFilters = receivedFilters
        }
        
        // 日記リスト取得イベント受信
        await store.receive(.receiveLoadDiaryItems(items: receivedItem)) {
            
            // 日記リスト更新
            $0.diaries = []
            // 日記リスト取得処理終了
            $0.viewState.isLoadingDiaries = false
            // 日記リストがあるかどうかのフラグ更新
            $0.viewState.hasDiaryItems = false
        }
        
        // 画面非表示
        await store.send(.onDisappearView)
    }
    
    // 日記リストをタップした時のケース
    @MainActor
    func testTappedDiaryItem() async throws {
                
        let diariesState: IdentifiedArray<UUID, DiaryListItemFeature.State> = [
            DiaryListItemFeature.State(title: "test1", message: "", date: Date(), isWin: true, trainingList: [], tagList: []),
         ]
        
        let store = TestStore(
            initialState: DiaryListFeature.State(diaries: diariesState)) {
                
            DiaryListFeature()
        }
        
        throw XCTSkip("ignore test. because don't complete target code.")
        
        // TODO: タップ後の画面遷移処理はまだ実装できていないので、実装後にテストの期待値を実装する
        // 日記リストのセルタップ時の動作
        await store.send(.diaries(.element(id: diariesState[0].id, action: .tappedDiaryItem))) { _ in
            
            // 編集画面をナビゲーションスタックに追加
//            $0.path.append(.detailScreen(.init()))
        }
    }
    
    // 日記項目削除確認アラートで削除を選択した時のケース
    @MainActor
    func testTappedDeleteItem() async {
        
        let diariesState: IdentifiedArray<UUID, DiaryListItemFeature.State> = [
            DiaryListItemFeature.State(title: "test1", message: "", date: Date(), isWin: true, trainingList: [], tagList: []),
            DiaryListItemFeature.State(title: "test2", message: "test message", date: Date(), isWin: true, trainingList: [], tagList: [])
         ]
        
        let viewState = DiaryListFeature.State.ViewState(hasDiaryItems: true)
        
        let store = TestStore(
            initialState: DiaryListFeature.State(diaries: diariesState, viewState: viewState)) {
                
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
        
        // 全ての日記リストを削除する
        
        // 削除確認アラートの表示
        await store.send(.diaries(.element(id: diariesState[1].id, action: .deleteItemSwipeAction))) {
            
            $0.alert = AlertState.createAlertStateWithCancel(.deleteDiaryItemConfirmAlert,
                                                             firstButtonHandler: .confirmDeleteItem(deleteItemId: diariesState[1].id))
        }
        
        // 日記項目削除確認アラートで削除を選択した時
        await store.send(.alert(.presented(.confirmDeleteItem(deleteItemId: diariesState[1].id)))) {
            
            // アラート削除
            $0.alert = nil
        }
        
        await store.receive(.deletedDiaryItem(id: diariesState[1].id)) {
            
            // 選択した日記項目が日記リストから削除されていること
            $0.diaries.remove(id: diariesState[1].id)
            // 日記リストがあるかどうかのフラグ更新
            $0.viewState.hasDiaryItems = false
        }
    }
    
    // 日記項目編集確認アラートで編集を選択した時のケース
    @MainActor
    func testTappedEditItem() async throws {
        
        let diariesState: IdentifiedArray<UUID, DiaryListItemFeature.State> = [
            DiaryListItemFeature.State(title: "test1", message: "", date: Date(), isWin: true, trainingList: [], tagList: []),
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
        
        throw XCTSkip("ignore test. because don't complete target code.")
        
        // TODO: 編集画面への遷移が未実装のため、実装後にテストの期待値を実装する
        // 日記項目編集確認アラートで編集を選択した時
        await store.send(.alert(.presented(.confirmEditItem(targetId: diariesState[0].id)))) {
            
            // アラート削除
            $0.alert = nil
            // 編集画面をナビゲーションスタックに追加
//            $0.path.append(.editScreen(.init()))
        }
    }
    
    // 日記作成ボタンを押下した時のケース
    @MainActor
    func testTappedAddDiaryButton() async throws {
        
        let store = TestStore(
            initialState: DiaryListFeature.State()) {
                
            DiaryListFeature()
        }
        
        throw XCTSkip("ignore test. because don't complete target code.")
        
        // TODO: 日記作成画面への遷移が未実装のため、実装後にテストの期待値を実装する
        // 日記作成ボタンを押下
        await store.send(.tappedCreateNewDiaryButton) { _ in
            
            // 日記作成画面をナビゲーションスタックに追加
//            $0.path.append(.createScreen(.init()))
        }
    }
    
    // グラフボタンを押下した時のケース
    @MainActor
    func testTappedGraphButton() async throws {
        
        let store = TestStore(
            initialState: DiaryListFeature.State()) {
                
            DiaryListFeature()
        }
        
        throw XCTSkip("ignore test. because don't complete target code.")
        
        // TODO: グラフ画面への遷移が未実装のため、実装後にテストの期待値を実装する
        // グラフボタンを押下
        await store.send(.tappedGraphButton) { _ in
            
            // グラフ画面をナビゲーションスタックに追加
//            $0.path.append(.graphScreen(.init()))
        }
    }
    
    // フィルターボタンを押下した時のケース
    @MainActor
    func testTappedFilterButton() async throws {
        
        let expectedItem = DiaryListItemFeature.State(title: "test", message: "test message", date: Date(), isWin: false, trainingList: [], tagList: [])
        let receivedFilters = [DiaryListFilterItem(target: .achievement, filterItemId: UUID(), value: "達成していない")]
        let changeFilters = [DiaryListFilterItem(target: .trainingType, filterItemId: UUID(), value: "腹筋")]
        let expectedDiariesAfterChangeFilter: IdentifiedArrayOf<DiaryListItemFeature.State> = []
        let filterPublisher = PassthroughSubject<[DiaryListFilterItem], Never>()
        
        let store = TestStore(initialState: DiaryListFeature.State(), reducer: { DiaryListFeature() }) {
            
            $0.diaryListFetchApi = DiaryListItemClient(fetch: { _, _ in
                
                return [expectedItem]
            }, deleteItem: { _ in })
            $0.diaryListFilterApi = DiaryListFilterClient.getFetchOnlyClientForTest(receivedFilters,
                                                                                    observer: filterPublisher.eraseToAnyPublisher())
            $0.date = DateGenerator({ Date() })
        }
        
        // 日記リスト画面表示時の動作
        await store.send(.onAppearView) {
            
            // 日記リスト取得処理開始
            $0.viewState.isLoadingDiaries = true
        }
        
        // 日記リストのフィルター取得イベント受信
        await store.receive(.receiveLoadDiaryListFilter(filters: receivedFilters)) {
            
            $0.currentFilters = receivedFilters
        }
        
        // 日記リスト取得イベント受信
        await store.receive(.receiveLoadDiaryItems(items: [expectedItem])) {
            
            // 日記リスト更新
            $0.diaries = [expectedItem]
            // 日記リスト取得処理終了
            $0.viewState.isLoadingDiaries = false
            // 日記リストがあるかどうかのフラグ更新
            $0.viewState.hasDiaryItems = true
        }
                
        // フィルターボタンを押下
        await store.send(.tappedFilterButton) {
            
            // フィルター画面を宛先に追加
            $0.destination = .filterScreen(DiaryListFilterFeature.State())
        }
        
        // フィルター画面のダイアログ外の領域タップ
        await store.send(.destination(.presented(.filterScreen(.tappedOutsideArea)))) {
            
            $0.destination = nil
        }
        
        // フィルターボタンを押下
        await store.send(.tappedFilterButton) {
            
            // フィルター画面を宛先に追加
            $0.destination = .filterScreen(DiaryListFilterFeature.State())
        }
        
        // フィルター更新
        filterPublisher.send(changeFilters)
        
        // 日記リストのフィルター取得イベント受信
        await store.receive(.receiveLoadDiaryListFilter(filters: changeFilters)) {
            
            $0.currentFilters = changeFilters
            $0.diaries = expectedDiariesAfterChangeFilter
        }
        
        // フィルター画面の閉じるボタンタップ
        await store.send(.destination(.presented(.filterScreen(.tappedCloseButton)))) {
            
            $0.destination = nil
        }
        
        // 画面非表示
        await store.send(.onDisappearView)
    }
}
