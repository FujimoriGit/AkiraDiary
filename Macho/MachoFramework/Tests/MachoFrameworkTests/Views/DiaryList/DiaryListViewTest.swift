//
//  DiaryListViewTest.swift
//
//
//  Created by 佐藤汰一 on 2024/06/01.
//

import Combine
import ComposableArchitecture
import RealmHelper
import XCTest

@testable import MachoView

final class DiaryListViewTests: XCTestCase {
    
    enum TestError: Error {
        
        case loadingError
    }
    
    /// アラートの表示確認
    ///
    /// # 確認仕様
    /// - 日記項目のスワイプアクションで削除を選択したら削除確認のアラートが表示されること
    /// - 日記項目のスワイプアクションで編集を選択したら編集確認のアラートが表示されること
    @MainActor
    func testAlert() async {
        
        let diariesState: IdentifiedArray<UUID, DiaryListItemFeature.State> = [
            .init(Self.getTestDiaryData(date: Self.fistDiaryDate)),
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
    @MainActor
    func testScrollBouncedDiaryList() async {
        
        let initialDiary1 = DiaryListItemFeature.State(Self.getTestDiaryData(date: Self.secondDiaryDate))
        let initialDiary2 = DiaryListItemFeature.State(Self.getTestDiaryData(date: Self.thirdDiaryDate))
                
        let expectedAddedItem = DiaryListItemFeature.State(Self.getTestDiaryData(date: Self.fistDiaryDate))
        
        let expectedLoadedDiaries = IdentifiedArray(uniqueElements: [
            expectedAddedItem,
            initialDiary1,
            initialDiary2
        ])
        
        // スクロール画面の表示サイズの高さが800px、スクロールできるサイズの高さが1000pxの状態
        let trackableListState = TrackableListFeature.State(offset: 0,
                                                            listSizeInfo: .init(containerSize: CGSize(width: 400, height: 800),
                                                                                contentSize: CGSize(width: 400, height: 1000)))
        
        let viewState = DiaryListFeature.State.ViewState(hasDiaryItems: true)
        
        let store = TestStore(
            initialState: DiaryListFeature.State(diaries: [
                initialDiary2,
                initialDiary1
            ], trackableList: trackableListState, viewState: viewState), reducer: { DiaryListFeature() }) {
                
                $0.diaryListFetchApi = .createCustomValue(getDiaryMockRealm([expectedAddedItem]))
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
    @MainActor
    func testOnAppearView() async {
        
        let expectedItem = DiaryListItemFeature.State(Self.getTestDiaryData(date: Self.fistDiaryDate,
                                                                            isWin: false))
        let receivedFilters = [DiaryListFilterItem(target: .achievement, filterItemId: Self.achievementId, value: "達成していない")]
        
        let store = TestStore(initialState: DiaryListFeature.State(), reducer: { DiaryListFeature() }) {
            
            $0.diaryListFetchApi = .createCustomValue(getDiaryMockRealm([expectedItem]))
            $0.diaryListFilterApi = .createCustomValue(getFilterMockRealm(receivedFilters))
            $0.date = DateGenerator({ Date() })
        }
        
        // 日記リスト画面表示時の動作
        await store.send(.onAppearView) {
            
            // 日記リスト取得処理開始
            $0.viewState.isLoadingDiaries = true
        }
        
        // 日記リストのフィルター取得イベント受信
        await store.receive(\.receiveLoadDiaryListFilter) {
            
            $0.currentFilters = receivedFilters
        }
        
        // 日記リスト取得イベント受信
        await store.receive(\.receiveLoadDiaryItems) {
            
            // 日記リスト更新
            $0.diaries = [expectedItem]
            $0.filteredDiaries = [expectedItem]
            // 日記リスト取得処理終了
            $0.viewState.isLoadingDiaries = false
            // 日記リストがあるかどうかのフラグ更新
            $0.viewState.hasDiaryItems = true
        }
        
        // 画面非表示
        await store.send(.onDisappearView)
    }
    
    /// 日記リストを保持している状態で画面表示時した時のケース
    @MainActor
    func testOnAppearViewWithAlreadyHasItems() async {
        
        let initialFirstItem = DiaryListItemFeature.State(Self.getTestDiaryData(date: Self.fistDiaryDate))
        let initialSecondItem = DiaryListItemFeature.State(Self.getTestDiaryData(date: Self.thirdDiaryDate))
        let expectedItem = DiaryListItemFeature.State(Self.getTestDiaryData(date: Self.secondDiaryDate,
                                                      isWin: false))
        
        let expectedFilteredDiaries = IdentifiedArray(uniqueElements: [
            initialFirstItem,
            initialSecondItem
        ])
        
        let expectedLoadedDiaries = IdentifiedArray(uniqueElements: [
            initialFirstItem,
            expectedItem,
            initialSecondItem
        ])
        
        let diariesState: IdentifiedArray<UUID, DiaryListItemFeature.State> = [
            initialSecondItem,
            initialFirstItem
         ]
        
        let receivedFilters = [
            DiaryListFilterItem(target: .achievement, filterItemId: Self.achievementId, value: "達成していない"),
            DiaryListFilterItem(target: .trainingType, filterItemId: Self.absTrainingId, value: "腹筋")
        ]
                
        let store = TestStore(initialState: DiaryListFeature.State(filteredDiaries: diariesState, diaries: diariesState),
                              reducer: { DiaryListFeature() }) {
            
            $0.diaryListFetchApi = .createCustomValue(getDiaryMockRealm([expectedItem]))
            $0.diaryListFilterApi = .createCustomValue(getFilterMockRealm(receivedFilters))
            $0.date = DateGenerator({ Date() })
        }
        
        // 日記リスト画面表示時の動作
        await store.send(.onAppearView) {
            
            // 日記リスト取得処理開始
            $0.viewState.isLoadingDiaries = true
        }
        
        // 日記リストのフィルター取得イベント受信
        await store.receive(\.receiveLoadDiaryListFilter) {
            
            $0.currentFilters = receivedFilters
            $0.diaries = expectedFilteredDiaries
            $0.filteredDiaries = expectedFilteredDiaries
        }
        
        // 日記リスト取得イベント受信
        await store.receive(\.receiveLoadDiaryItems) {
            
            // 日記リスト更新
            $0.diaries = expectedLoadedDiaries
            $0.filteredDiaries = expectedLoadedDiaries
            // 日記リスト取得処理終了
            $0.viewState.isLoadingDiaries = false
            // 日記リストがあるかどうかのフラグ更新
            $0.viewState.hasDiaryItems = true
        }
        
        // 画面非表示
        await store.send(.onDisappearView)
    }
    
    /// フィルターにヒットする日記がないケース
    ///
    /// # 仕様確認
    /// - フィルターに一つ以上合致しない日記リストは表示しない
    @MainActor
    func testOnAppearViewWithNoHitsFilter() async {
        
        let benchPressWinItem = Self.getTestDiaryData(date: Self.fistDiaryDate, training: Self.benchPress)
        let plunkLoseItem = Self.getTestDiaryData(date: Self.thirdDiaryDate, training: Self.plunk)
        let benchPressLoseItem = Self.getTestDiaryData(date: Self.secondDiaryDate, training: Self.benchPress)
        
        let receivedItem = [
            DiaryListItemFeature.State(benchPressWinItem),
            DiaryListItemFeature.State(benchPressLoseItem),
            DiaryListItemFeature.State(plunkLoseItem)
        ]
        
        let receivedFilters = [
            DiaryListFilterItem(target: .achievement, filterItemId: Self.achievementId, value: "達成していない"),
            DiaryListFilterItem(target: .trainingType, filterItemId: Self.absTrainingId, value: "腹筋"),
            DiaryListFilterItem(target: .trainingType, filterItemId: Self.squatTrainingId, value: "スクワット"),
            DiaryListFilterItem(target: .tag, filterItemId: Self.tag2Id, value: "晴れ")
        ]
        
        let store = TestStore(initialState: DiaryListFeature.State(),
                              reducer: { DiaryListFeature() }) {
            
            $0.diaryListFetchApi = .createCustomValue(getDiaryMockRealm(receivedItem))
            $0.diaryListFilterApi = .createCustomValue(getFilterMockRealm(receivedFilters))
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
        await store.receive(\.receiveLoadDiaryItems) {
            
            // 日記リスト更新
            $0.diaries = IdentifiedArray(uniqueElements: receivedItem)
            $0.filteredDiaries = []
            // 日記リスト取得処理終了
            $0.viewState.isLoadingDiaries = false
            // 日記リストがあるかどうかのフラグ更新
            $0.viewState.hasDiaryItems = false
        }
        
        // 画面非表示
        await store.send(.onDisappearView)
    }
    
    /// 日記リストをタップした時のケース
    ///
    /// # 仕様確認
    /// - 日記リストのセルをタップしたら日記した日記情報の詳細画面に遷移する
    @MainActor
    func testTappedDiaryItem() async throws {
                
        let diariesState: IdentifiedArray<UUID, DiaryListItemFeature.State> = [
            DiaryListItemFeature.State(Self.getTestDiaryData(date: Date())),
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
    @MainActor
    func testTappedDeleteItem() async {
        
        let diariesState: IdentifiedArray<UUID, DiaryListItemFeature.State> = [
            DiaryListItemFeature.State(Self.getTestDiaryData(date: Date())),
            DiaryListItemFeature.State(Self.getTestDiaryData(date: Date()))
         ]
        
        let viewState = DiaryListFeature.State.ViewState(hasDiaryItems: true)
        
        let store = TestStore(
            initialState: DiaryListFeature.State(filteredDiaries: diariesState, diaries: diariesState, viewState: viewState)) {
                
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
    @MainActor
    func testTappedEditItem() async throws {
        
        let diariesState: IdentifiedArray<UUID, DiaryListItemFeature.State> = [
            DiaryListItemFeature.State(Self.getTestDiaryData(date: Date())),
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
    
    /// グラフボタンを押下した時のケース
    ///
    /// # 仕様確認
    /// - グラフボタンを押下するとグラフ画面に遷移する
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
    @MainActor
    func testTappedFilterButton() async throws {
        
        let expectedItems = IdentifiedArray(uniqueElements: [DiaryListItemFeature.State(Self.getTestDiaryData(date: Self.fistDiaryDate, isWin: false, training: Self.plunk)),])
        let receivedFilters = [DiaryListFilterItem(target: .achievement, filterItemId: Self.achievementId, value: "達成していない")]
        let changeFilters = [DiaryListFilterItem(target: .trainingType, filterItemId: Self.absTrainingId, value: "腹筋")]
        let expectedDiariesAfterChangeFilter: IdentifiedArrayOf<DiaryListItemFeature.State> = []
        let filterPublisher = PassthroughSubject<[DiaryListFilterItem], Never>()
        
        let store = TestStore(initialState: DiaryListFeature.State(), reducer: { DiaryListFeature() }) {
            
            $0.diaryListFetchApi = .createCustomValue(getDiaryMockRealm(expectedItems.elements))
            $0.diaryListFilterApi = .createCustomValue(getFilterMockRealm(receivedFilters)) {
                
                return filterPublisher.eraseToAnyPublisher()
            }
            $0.date = DateGenerator({ Date() })
        }
        
        // 日記リスト画面表示時の動作
        await store.send(.onAppearView) {
            
            // 日記リスト取得処理開始
            $0.viewState.isLoadingDiaries = true
        }
        
        // 日記リストのフィルター取得イベント受信
        await store.receive(\.receiveLoadDiaryListFilter) {
            
            $0.currentFilters = receivedFilters
        }
        
        // 日記リスト取得イベント受信
        await store.receive(\.receiveLoadDiaryItems) {
            
            // 日記リスト更新
            $0.diaries = expectedItems
            // フィルター反映後の日記リスト
            $0.filteredDiaries = expectedItems
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
        await store.receive(\.receiveLoadDiaryListFilter) {
            
            $0.currentFilters = changeFilters
            $0.filteredDiaries = expectedDiariesAfterChangeFilter
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
        filterPublisher.send([])
        
        // 日記リストのフィルター取得イベント受信
        await store.receive(\.receiveLoadDiaryListFilter) {
            
            $0.currentFilters = []
            $0.filteredDiaries = expectedItems
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
                                                     startTime: Date(),
                                                     endTime: Date())],
                         tags: [tag ?? Self.tag1])
    }
}

// MARK: - utility

private extension DiaryListViewTests {
    
    func getFilterMockRealm(_ expectedReceiveFilter: [DiaryListFilterItem]) -> RealmAccessorMock<DiaryListFilterEntity> {
        
        // filterApiのモックRealm設定
        return RealmAccessorMock(fetchEntity: expectedReceiveFilter.map {
            
            DiaryListFilterEntity(id: $0.id,
                                  filterTarget: $0.target.rawValue,
                                  filterId: $0.filterItemId,
                                  filterValue: $0.value)
        })
    }
    
    func getDiaryMockRealm(_ expectedReceiveDiary: [DiaryListItemFeature.State]) -> RealmAccessorMock<DiaryEntity> {
        
        return RealmAccessorMock(fetchEntity: expectedReceiveDiary.map(\.entity))
    }
}
