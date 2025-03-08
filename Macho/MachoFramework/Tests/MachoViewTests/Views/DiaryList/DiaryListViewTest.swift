//
//  DiaryListViewTest.swift
//
//
//  Created by 佐藤汰一 on 2024/06/01.
//

import ComposableArchitecture
import XCTest

@testable import MachoCore
@testable import MachoView
@testable import RealmHelper

@MainActor
final class DiaryListViewTests: XCTestCase {
    
    enum TestError: Error {
        
        case loadingError
    }
    
    /// アラートの表示確認
    ///
    /// # 確認仕様
    /// - 日記項目のスワイプアクションで削除を選択したら削除確認のアラートが表示されること
    /// - 日記項目のスワイプアクションで編集を選択したら編集確認のアラートが表示されること
    func testAlert() async {
        
        let diariesState: IdentifiedArray<UUID, DiaryListItemFeature.State> = [
            .init(entity: Self.getTestDiaryData(date: Self.fistDiaryDate)),
         ]
        
        let store = TestStore(
            initialState: DiaryListFeature.State(filteredDiaries: diariesState, diaries: diariesState)) {
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
    }
    
    /// 日記リスト画面をスクロールした時のケース
    ///
    /// # 仕様確認
    /// - 下にバウンスするまでスクロールした場合、以下を行うこと
    ///   - スクロール状態に更新すること
    ///   - ロード状態に更新する
    ///   - 日記の追加取得を行うこと
    /// - 一番上前スクロールした場合、スクロール状態をスクロールしていない状態に更新する
    func testScrollBouncedDiaryList() async throws {
        
        let inputDiaries = [
            Self.getTestDiaryData(date: Self.fistDiaryDate),
            Self.getTestDiaryData(date: Self.secondDiaryDate),
            Self.getTestDiaryData(date: Self.thirdDiaryDate)
        ]
        
        // スクロール画面の表示サイズの高さが800px、スクロールできるサイズの高さが1000pxの状態
        let trackableListState = TrackableListFeature.State(offset: 0,
                                                            listSizeInfo: .init(containerSize: CGSize(width: 400, height: 800),
                                                                                contentSize: CGSize(width: 400, height: 1000)))
        
        let viewState = DiaryListFeature.State.ViewState(hasDiaryItems: true)
        
        let mockRealm = try await RealmTestHelper.getMockRealm()
        let mockDiaryClient = DiaryEntityClient.getMockClient(realm: mockRealm)
        await setupDiaryDataList(mockDiaryClient, diaryList: inputDiaries)
        
        let store = TestStore(
            initialState: DiaryListFeature.State(diaries: [
                .init(entity: inputDiaries[0]),
                .init(entity: inputDiaries[1])
            ], trackableList: trackableListState, viewState: viewState), reducer: { DiaryListFeature() }) {
                
                $0.diaryEntityClient = mockDiaryClient
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
        await store.receive(\.receiveLoadDiaryItems) {
            
            // 日記リストのロード処理終了
            $0.viewState.isLoadingDiaries = false
            // 日記リストの更新
            let expectedLoadedDiaries: IdentifiedArrayOf<DiaryListItemFeature.State> = IdentifiedArray(
                uniqueElements: inputDiaries.map { .init(entity: $0) }
            )
            $0.diaries = expectedLoadedDiaries
            $0.filteredDiaries = expectedLoadedDiaries
        }
        
        // 上にスクロールして一番上の画面に戻る
        await store.send(.trackableList(TrackableListFeature.Action.onScroll(offset: 0))) {
            
            // リスト画面のoffset更新
            $0.trackableList.offset = 0
            // スクロール中でない
            $0.viewState.isScrolling = false
        }
    }
    
    /// 日記リスト初回画面表示時に日記リスト取得成功した時のケース
    ///
    /// # 仕様確認
    /// - 画面表示時に以下を行う
    ///   - フィルターを取得する
    ///   - 日記リストの取得を行う
    func testOnAppearView() async throws {
        
        let inputDiary = Self.getTestDiaryData(date: Self.fistDiaryDate, isWin: false)
        let inputFilters = [DiaryListFilterData(target: .achievement,
                                                        filterItemId: Self.achievementId,
                                                        value: "達成していない")]
        
        let mockRealm = try await RealmTestHelper.getMockRealm()
        let mockDiaryClient = DiaryEntityClient.getMockClient(realm: mockRealm)
        let mockDiaryFilterClient = DiaryListFilterClient.getMockClient(realm: mockRealm)
        await setupDiaryDataList(mockDiaryClient, diaryList: [inputDiary])
        await setupDiaryFilterList(mockDiaryFilterClient, filterList: inputFilters)
        
        let store = TestStore(initialState: DiaryListFeature.State(), reducer: { DiaryListFeature() }) {
            
            $0.diaryEntityClient = mockDiaryClient
            $0.diaryListFilterClient = mockDiaryFilterClient
            $0.date = DateGenerator({ Date() })
        }
        
        // 日記リスト画面表示時の動作
        await store.send(.onAppearView) {
            
            // 日記リスト取得処理開始
            $0.viewState.isLoadingDiaries = true
        }
        
        // 日記リストのフィルター取得イベント受信
        await store.receive(\.receiveLoadDiaryListFilter) {
            
            $0.currentFilters = inputFilters.map { .init(entity: $0) }
        }
        
        // 日記リスト取得イベント受信
        await store.receive(\.receiveLoadDiaryItems) {
            
            // 日記リスト更新
            let expectedItem = DiaryListItemFeature.State(entity: inputDiary)
            $0.diaries = [expectedItem]
            $0.filteredDiaries = [expectedItem]
            // 日記リスト取得処理終了
            $0.viewState.isLoadingDiaries = false
            // 日記リストがあるかどうかのフラグ更新
            $0.viewState.hasDiaryItems = true
        }
        
        await store.receive(\.startFilterItemObserve)
        
        // 画面非表示
        await store.send(.onDisappearView)
    }
    
    /// 日記リストを保持している状態で画面表示時した時のケース
    func testOnAppearViewWithAlreadyHasItems() async throws {
        
        let inputDiaryList = [
            Self.getTestDiaryData(date: Self.fistDiaryDate),
            Self.getTestDiaryData(date: Self.secondDiaryDate, isWin: false),
            Self.getTestDiaryData(date: Self.thirdDiaryDate)
        ]
        
        let inputFilters = [
            DiaryListFilterData(target: .achievement, filterItemId: Self.achievementId, value: "達成していない"),
            DiaryListFilterData(target: .trainingType, filterItemId: Self.absTrainingId, value: "腹筋")
        ]
        
        let mockRealm = try await RealmTestHelper.getMockRealm()
        let mockDiaryClient = DiaryEntityClient.getMockClient(realm: mockRealm)
        let mockDiaryFilterClient = DiaryListFilterClient.getMockClient(realm: mockRealm)
        await setupDiaryDataList(mockDiaryClient, diaryList: inputDiaryList)
        await setupDiaryFilterList(mockDiaryFilterClient, filterList: inputFilters)
        
        let diariesState: IdentifiedArray<UUID, DiaryListItemFeature.State> = [
            .init(entity: inputDiaryList[0]),
            .init(entity: inputDiaryList[1])
         ]
        
        let store = TestStore(initialState: DiaryListFeature.State(filteredDiaries: diariesState, diaries: diariesState),
                              reducer: { DiaryListFeature() }) {
            
            $0.diaryEntityClient = mockDiaryClient
            $0.diaryListFilterClient = mockDiaryFilterClient
            $0.date = DateGenerator({ Date() })
        }
        
        // 日記リスト画面表示時の動作
        await store.send(.onAppearView) {
            
            // 日記リスト取得処理開始
            $0.viewState.isLoadingDiaries = true
        }
        
        // 日記リストのフィルター取得イベント受信
        await store.receive(\.receiveLoadDiaryListFilter) {
            
            $0.currentFilters = inputFilters.map { .init(entity: $0) }
        }
        
        // 日記リスト取得イベント受信
        await store.receive(\.receiveLoadDiaryItems) {
            
            // 日記リスト更新
            let expectedLoadedDiaries: IdentifiedArrayOf<DiaryListItemFeature.State> = IdentifiedArray(uniqueElements: inputDiaryList.map { .init(entity: $0) })
            $0.diaries = expectedLoadedDiaries
            $0.filteredDiaries = expectedLoadedDiaries
            // 日記リスト取得処理終了
            $0.viewState.isLoadingDiaries = false
            // 日記リストがあるかどうかのフラグ更新
            $0.viewState.hasDiaryItems = true
        }
        
        await store.receive(\.startFilterItemObserve)
        
        // 画面非表示
        await store.send(.onDisappearView)
    }
    
    /// フィルターにヒットする日記がないケース
    ///
    /// # 仕様確認
    /// - フィルターに一つ以上合致しない日記リストは表示しない
    func testOnAppearViewWithNoHitsFilter() async throws {
        
        let inputDiaryList = [
            Self.getTestDiaryData(date: Self.fistDiaryDate, training: Self.benchPress),
            Self.getTestDiaryData(date: Self.secondDiaryDate, training: Self.benchPress),
            Self.getTestDiaryData(date: Self.thirdDiaryDate, training: Self.plunk)
        ]
        let inputFilters = [
            DiaryListFilterData(target: .achievement, filterItemId: Self.achievementId, value: "達成していない"),
            DiaryListFilterData(target: .trainingType, filterItemId: Self.absTrainingId, value: "腹筋"),
            DiaryListFilterData(target: .trainingType, filterItemId: Self.squatTrainingId, value: "スクワット"),
            DiaryListFilterData(target: .tag, filterItemId: Self.tag2Id, value: "晴れ")
        ]
        
        let mockRealm = try await RealmTestHelper.getMockRealm()
        let mockDiaryClient = DiaryEntityClient.getMockClient(realm: mockRealm)
        let mockDiaryFilterClient = DiaryListFilterClient.getMockClient(realm: mockRealm)
        await setupDiaryDataList(mockDiaryClient, diaryList: inputDiaryList)
        await setupDiaryFilterList(mockDiaryFilterClient, filterList: inputFilters)
        
        let store = TestStore(initialState: DiaryListFeature.State(),
                              reducer: { DiaryListFeature() }) {
            
            $0.diaryEntityClient = mockDiaryClient
            $0.diaryListFilterClient = mockDiaryFilterClient
            $0.date = DateGenerator({ Date() })
        }
        
        // 日記リスト画面表示時の動作
        await store.send(.onAppearView) {
            
            // 日記リスト取得処理開始
            $0.viewState.isLoadingDiaries = true
        }
        
        // 日記リストのフィルター取得イベント受信
        await store.receive(\.receiveLoadDiaryListFilter) {
            
            $0.currentFilters = inputFilters.map { .init(entity: $0) }
        }
        
        // 日記リスト取得イベント受信
        await store.receive(\.receiveLoadDiaryItems) {
            
            // 日記リスト更新
            let receivedItem = inputDiaryList.map { DiaryListItemFeature.State(entity: $0) }
            $0.diaries = IdentifiedArray(uniqueElements: receivedItem)
            $0.filteredDiaries = []
            // 日記リスト取得処理終了
            $0.viewState.isLoadingDiaries = false
            // 日記リストがあるかどうかのフラグ更新
            $0.viewState.hasDiaryItems = false
        }
        
        await store.receive(\.startFilterItemObserve)
        
        // 画面非表示
        await store.send(.onDisappearView)
    }
    
    /// 日記リストをタップした時のケース
    ///
    /// # 仕様確認
    /// - 日記リストのセルをタップしたら日記した日記情報の詳細画面に遷移する
    func testTappedDiaryItem() async throws {
        
        let diariesState: IdentifiedArray<UUID, DiaryListItemFeature.State> = [
            DiaryListItemFeature.State(entity: Self.getTestDiaryData(date: Date())),
         ]
        
        let store = TestStore(
            initialState: DiaryListFeature.State(filteredDiaries: diariesState, diaries: diariesState)) {
                
                DiaryListFeature()
            }
        
        // 日記リストのセルタップ時の動作
        await store.send(.diaries(.element(id: diariesState[0].id, action: .tappedDiaryItem))) {
            
            // 編集画面をナビゲーションスタックに追加
            $0.path.append(.detailScreen(.init(diary: diariesState.first!.entity)))
        }
    }
    
    /// 日記項目削除確認アラートで削除を選択した時のケース
    ///
    /// # 仕様確認
    /// - 日記リストのスワイプアクションで削除を選択すると削除確認アラートが表示されること
    /// - 削除アラートで削除を選択したとき、選択した日記が日記リストから削除されること
    func testTappedDeleteItem() async throws {
        
        let inputDiaryList = [
            Self.getTestDiaryData(date: Date()),
            Self.getTestDiaryData(date: Date())
        ]
        
        let viewState = DiaryListFeature.State.ViewState(hasDiaryItems: true)
        
        let mockRealm = try await RealmTestHelper.getMockRealm()
        let mockDiaryClient = DiaryEntityClient.getMockClient(realm: mockRealm)
        await setupDiaryDataList(mockDiaryClient, diaryList: inputDiaryList)
        
        let diariesState = IdentifiedArray(uniqueElements: inputDiaryList.map { DiaryListItemFeature.State(entity: $0) })
        let store = TestStore(
            initialState: DiaryListFeature.State(filteredDiaries: diariesState,
                                                 diaries: diariesState,
                                                 viewState: viewState)) {
                
                DiaryListFeature()
            } withDependencies: {
                
                $0.diaryEntityClient = mockDiaryClient
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
        
        await store.receive(\.deletedDiaryItem) {
            
            // 選択した日記項目が日記リストから削除されていること
            $0.diaries.remove(id: diariesState[0].id)
            $0.filteredDiaries.remove(id: diariesState[0].id)
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
        
        await store.receive(\.deletedDiaryItem) {
            
            // 選択した日記項目が日記リストから削除されていること
            $0.diaries.remove(id: diariesState[1].id)
            $0.filteredDiaries.remove(id: diariesState[1].id)
            // 日記リストがあるかどうかのフラグ更新
            $0.viewState.hasDiaryItems = false
        }
    }
    
    /// 日記項目編集確認アラートで編集を選択した時のケース
    ///
    /// # 仕様確認
    /// - 日記リストのスワイプアクションで編集を選択すると編集確認アラートが表示されること
    /// - 編集を選択すると選択した日記の編集画面に遷移する
    func testTappedEditItem() async throws {
        
        let diariesState: IdentifiedArray<UUID, DiaryListItemFeature.State> = [
            DiaryListItemFeature.State(entity: Self.getTestDiaryData(date: Date())),
         ]
        
        let store = TestStore(
            initialState: DiaryListFeature.State(filteredDiaries: diariesState, diaries: diariesState)) {
                
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
    
    /// 日記作成ボタンを押下した時のケース
    ///
    /// # 仕様確認
    /// - 日記作成ボタンを押下すると、日記作成画面に遷移する
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
    
    /// グラフボタンを押下した時のケース
    ///
    /// # 仕様確認
    /// - グラフボタンを押下するとグラフ画面に遷移する
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
    
    /// フィルターボタンを押下した時のケース
    ///
    /// # 仕様確認
    /// - 画面表示時に設定フィルターの監視を行う
    /// - フィルターボタンを押下するとフィルター画面が表示される
    /// - フィルター画面のダイアログ外の領域をタップすると、リスト画面に戻る
    /// - フィルター画面で設定フィルターの更新が行われると、リスト画面の設定フィルターにも変更後のフィルターが反映される
    /// - フィルター画面の閉じるボタンを押下されると、リスト画面に戻る
    /// - フィルターを全て削除すると、フィルター適用前の日記が全て表示される
    /// - リスト画面が非表示になると、フィルター監視を終了する
    func testTappedFilterButton() async throws {
        
        let inputDiaryList = [
            Self.getTestDiaryData(date: Self.fistDiaryDate, isWin: false, training: Self.plunk)
        ]
        let inputFilters = [
            DiaryListFilterData(target: .achievement, filterItemId: Self.achievementId, value: "達成していない")
        ]
        
        let mockRealm = try await RealmTestHelper.getMockRealm()
        let mockDiaryClient = DiaryEntityClient.getMockClient(realm: mockRealm)
        let mockDiaryFilterClient = DiaryListFilterClient.getMockClient(realm: mockRealm)
        await setupDiaryDataList(mockDiaryClient, diaryList: inputDiaryList)
        await setupDiaryFilterList(mockDiaryFilterClient, filterList: inputFilters)
        
        let store = TestStore(initialState: DiaryListFeature.State(), reducer: { DiaryListFeature() }) {
            
            $0.diaryEntityClient = mockDiaryClient
            $0.diaryListFilterClient = mockDiaryFilterClient
            $0.date = DateGenerator({ Date() })
        }
        
        // 日記リスト画面表示時の動作
        await store.send(.onAppearView) {
            
            // 日記リスト取得処理開始
            $0.viewState.isLoadingDiaries = true
        }
        
        // 日記リストのフィルター取得イベント受信
        await store.receive(\.receiveLoadDiaryListFilter) {
            
            $0.currentFilters = inputFilters.map { .init(entity: $0) }
        }
        
        // 日記リスト取得イベント受信
        let expectedFullDiaryList = IdentifiedArrayOf<DiaryListItemFeature.State>(uniqueElements: inputDiaryList.map { .init(entity: $0) })
        await store.receive(\.receiveLoadDiaryItems) {
            
            // 日記リスト更新
            $0.diaries = expectedFullDiaryList
            // フィルター反映後の日記リスト
            $0.filteredDiaries = expectedFullDiaryList
            // 日記リスト取得処理終了
            $0.viewState.isLoadingDiaries = false
            // 日記リストがあるかどうかのフラグ更新
            $0.viewState.hasDiaryItems = true
        }
        
        await store.receive(\.startFilterItemObserve)
        
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
        let addFilter = DiaryListFilterData(target: .trainingType, filterItemId: Self.absTrainingId, value: "腹筋")
        let addResult = await mockDiaryFilterClient.addFilter(addFilter)
        XCTAssertTrue(addResult)
        
        // 日記リストのフィルター取得イベント受信
        await store.receive(\.receiveLoadDiaryListFilter) {
            
            $0.currentFilters.append(.init(entity: addFilter))
        }
        
        // フィルター画面の閉じるボタンタップ
        await store.send(.destination(.presented(.filterScreen(.tappedCloseButton)))) {
            
            $0.destination = nil
        }
        
        // フィルターを全て削除する
        
        // フィルターボタンを押下
        await store.send(.tappedFilterButton) {
            
            // フィルター画面を宛先に追加
            $0.destination = .filterScreen(DiaryListFilterFeature.State())
        }
        
        // フィルター更新
        let deleteResult = await mockDiaryFilterClient.deleteFilters(inputFilters + [addFilter])
        XCTAssertTrue(deleteResult)
        
        // 日記リストのフィルター取得イベント受信
        await store.receive(\.receiveLoadDiaryListFilter) {
            
            $0.currentFilters = []
            $0.filteredDiaries = expectedFullDiaryList
        }
        
        // 画面非表示
        await store.send(.onDisappearView)
    }
}

// MARK: - constant definition

private extension DiaryListViewTests {
    
    // フィルターID
    private static let achievementId = UUID(DiaryListFilterTarget.achievement.num)
    private static let absTrainingId = UUID()
    private static let squatTrainingId = UUID()
    private static let plunkTrainingId = UUID()
    private static let benchPressTrainingId = UUID()
    private static let tag1Id = UUID()
    private static let tag2Id = UUID()
    
    static let abs = TrainingTypeData(id: absTrainingId, name: "腹筋")
    static let squat = TrainingTypeData(id: squatTrainingId, name: "スクワット")
    static let plunk = TrainingTypeData(id: plunkTrainingId, name: "プランク")
    static let benchPress = TrainingTypeData(id: benchPressTrainingId, name: "ベンチプレス")
    
    static let tag1 = TrainingTagData(id: tag1Id, tagName: "元気")
    static let tag2 = TrainingTagData(id: tag2Id, tagName: "晴れ")
    
    static let fistDiaryDate = Date()
    static let secondDiaryDate = Calendar.current.date(byAdding: .minute, value: -1, to: fistDiaryDate)!
    static let thirdDiaryDate = Calendar.current.date(byAdding: .minute, value: -2, to: fistDiaryDate)!
    
    static func getTestDiaryData(date: Date,
                                 isWin: Bool = true,
                                 training: TrainingTypeData? = nil,
                                 tag: TrainingTagData? = nil) -> DiaryData {
        
        return DiaryData(id: UUID(),
                         date: date,
                         title: "test",
                         mainText: "test message",
                         goals: [TrainingContentData(id: UUID(),
                                                     trainingType: training ?? Self.abs,
                                                     goalNumberOfSets: 3,
                                                     goalSetCount: 3,
                                                     actualNumberOfSets: isWin ? 3 : 1,
                                                     actualSetCount: 3,
                                                     isAchieved: isWin)],
                         tags: [tag ?? Self.tag1],
                         startTime: Date(),
                         endTime: Date())
    }
    
    func setupDiaryFilterList(_ client: DiaryListFilterClient,
                              filterList: [DiaryListFilterData]) async {
        
        for filter in filterList {
            
            let result = await client.addFilter(filter)
            XCTAssertTrue(result)
        }
    }
    
    func setupDiaryDataList(_ client: DiaryEntityClient, diaryList: [DiaryData]) async {
        
        for diary in diaryList {
            
            let result = await client.add(diary)
            XCTAssertTrue(result)
        }
    }
}

extension DiaryListFilterItem {
    
    init(entity: DiaryListFilterData) {
        
        self.init(target: DiaryListFilterTarget(rawValue: entity.filterTarget)!,
                  filterItemId: entity.filterId,
                  value: entity.filterValue)
    }
}
