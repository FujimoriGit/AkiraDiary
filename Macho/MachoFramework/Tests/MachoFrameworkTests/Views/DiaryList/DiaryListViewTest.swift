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

@MainActor
final class DiaryListViewTests: XCTestCase {
    
    // フィルターID
    private static let achievementId = UUID(DiaryListFilterTarget.achievement.num)
    
    func test_日記リストが下にバウンスした時ぐるぐるを表示して古い日記を取得する() async throws {
        
        let initialDiary = DiaryListItemFeature.State(.create(date: .distantFuture))
        let expectedAddedItem = DiaryListItemFeature.State(.create(date: .distantPast))
        let expectedLoadedDiaries = IdentifiedArray(uniqueElements: [
            initialDiary,
            expectedAddedItem
        ])
        
        // スクロール画面の表示サイズの高さが800px、スクロールできるサイズの高さが1000pxの状態
        let trackableListState = TrackableListFeature.State(
            offset: 0,
            listSizeInfo: .init(containerSize: CGSize(width: 400, height: 800),
                                contentSize: CGSize(width: 400, height: 1000))
        )
        let viewState = DiaryListFeature.State.ViewState(hasDiaryItems: true)
        let store = TestStore(
            initialState: DiaryListFeature.State(
                diaries: [initialDiary],
                trackableList: trackableListState,
                viewState: viewState
            ), reducer: { DiaryListFeature() }) {
                
                $0.diaryListFetchApi = .createCustomValue(getDiaryMockRealm([expectedAddedItem]))
            }
        
        // 300pxスクロールして下にバウンスが発生
        await store.send(.trackableList(TrackableListFeature.Action.onScroll(offset: -300))) {
            
            $0.trackableList.offset = -300
            $0.viewState.isScrolling = true
            $0.viewState.isLoadingDiaries = true
        }
        
        await store.receive(\.receiveLoadDiaryItems) {
            
            $0.viewState.isLoadingDiaries = false
            $0.diaries = expectedLoadedDiaries
            $0.filteredDiaries = expectedLoadedDiaries
        }
    }
    
    func test_スクロールしている状態から最上部までスクロールして元の位置に戻るとヘッダーが表示される() async {
        
        // スクロール画面の表示サイズの高さが800px、スクロールできるサイズの高さが1000pxの状態
        let trackableListState = TrackableListFeature.State(offset: -300,
                                                            listSizeInfo: .init(containerSize: CGSize(width: 400, height: 800),
                                                                                contentSize: CGSize(width: 400, height: 1000)))
        
        let viewState = DiaryListFeature.State.ViewState(isScrolling: true, hasDiaryItems: true)
        
        let store = TestStore(
            initialState: DiaryListFeature.State(
                diaries: [.init(.create())],
                trackableList: trackableListState,
                viewState: viewState),
            reducer: { DiaryListFeature() })
        
        // 上にスクロールして一番上の画面に戻る
        await store.send(.trackableList(TrackableListFeature.Action.onScroll(offset: 0))) {
            
            $0.trackableList.offset = 0
            $0.viewState.isScrolling = false
        }
    }
    
    func test_画面表示時に前回のフィルター内容でフィルタリングした日記リストを表示する() async {
        
        let expectedItem = DiaryListItemFeature.State(.create(goals: [.create(isAchieved: false)]))
        let receivedFilters = [DiaryListFilterItem(target: .achievement, filterItemId: Self.achievementId, value: "達成していない")]
        
        let store = TestStore(initialState: DiaryListFeature.State(),
                              reducer: { DiaryListFeature() }) {
            
            $0.diaryListFetchApi = .createCustomValue(getDiaryMockRealm([expectedItem]))
            $0.diaryListFilterApi = .createCustomValue(getFilterMockRealm(receivedFilters))
            $0.date = DateGenerator({ Date() })
        }
        
        // 実行
        
        await store.send(.onAppearView) {
            
            // 検証
            
            $0.viewState.isLoadingDiaries = true
        }
        
        await store.receive(\.receiveLoadDiaryListFilter) {
            
            $0.currentFilters = receivedFilters
        }
        
        await store.receive(\.receiveLoadDiaryItems) {
            
            $0.diaries = [expectedItem]
            $0.filteredDiaries = [expectedItem]
            $0.viewState.isLoadingDiaries = false
            $0.viewState.hasDiaryItems = true
        }
    }
    
    func test_日記作成画面で日記追加後に日記リストに戻ったら追加した日記をリストに表示する() async {
        
        let initialFirstItem = DiaryListItemFeature.State(.create(
            date: .create(year: 2025, month: 2, day: 1))
        )
        let fetchedNewItem = DiaryListItemFeature.State(.create(
            date: .create(year: 2025, month: 1, day: 1))
        )
                        
        let store = TestStore(
            initialState: DiaryListFeature.State(
                filteredDiaries: .init(uniqueElements: [initialFirstItem]),
                diaries: .init(uniqueElements: [initialFirstItem]),
                viewState: .init(hasDiaryItems: true)
            ),
            reducer: { DiaryListFeature() }
        ) {
            
            $0.diaryListFetchApi = .createCustomValue(getDiaryMockRealm([
                initialFirstItem,
                fetchedNewItem
            ]))
            $0.diaryListFilterApi = .createCustomValue(getFilterMockRealm([]))
            $0.date = DateGenerator({ .create(year: 2025, month: 2, day: 2) })
        }
        
        // 日記リスト画面表示時の動作
        await store.send(.onAppearView) {
            
            // 日記リスト取得処理開始
            $0.viewState.isLoadingDiaries = true
        }
        
        // 日記リストのフィルター取得イベント受信
        await store.receive(\.receiveLoadDiaryListFilter)
        
        // 日記リスト取得イベント受信
        await store.receive(\.receiveLoadDiaryItems) {
            
            let expectedLoadedDiaries = IdentifiedArray(uniqueElements: [
                initialFirstItem,
                fetchedNewItem
            ])
            $0.diaries = expectedLoadedDiaries
            $0.filteredDiaries = expectedLoadedDiaries
            $0.viewState.isLoadingDiaries = false
            $0.viewState.hasDiaryItems = true
        }
    }
    
    func test_日記項目をタップすると日記詳細画面へ遷移する() async throws {
                
        let diariesState: IdentifiedArray<UUID, DiaryListItemFeature.State> = [
            DiaryListItemFeature.State(.create())
         ]
        
        let store = TestStore(
            initialState: DiaryListFeature.State(filteredDiaries: diariesState,
                                                 diaries: diariesState)) {
                
            DiaryListFeature()
        }
        
        // 日記リストのセルタップ時の動作
        await store.send(.diaries(.element(id: diariesState[0].id, action: .tappedDiaryItem))) {
            
            // 編集画面をナビゲーションスタックに追加
            $0.path.append(.detailScreen(.init(diary: diariesState.first!.entity)))
        }
    }
    
    func test_日記項目の左スワイプで削除ボタンを押下すると削除確認アラートを表示する() async {
        
        let diariesState: IdentifiedArray<UUID, DiaryListItemFeature.State> = [
            DiaryListItemFeature.State(.create()),
         ]
        
        let viewState = DiaryListFeature.State.ViewState(hasDiaryItems: true)
        
        let store = TestStore(
            initialState: DiaryListFeature.State(filteredDiaries: diariesState,
                                                 diaries: diariesState,
                                                 viewState: viewState)) {
                
            DiaryListFeature()
        }
        
        // 削除確認アラートの表示
        await store.send(.diaries(.element(id: diariesState[0].id, action: .deleteItemSwipeAction))) {
            
            $0.alert = AlertState.createAlertStateWithCancel(.deleteDiaryItemConfirmAlert,
                                                             firstButtonHandler: .confirmDeleteItem(deleteItemId: diariesState[0].id))
        }
    }
    
    func test_削除確認アラートで削除するボタンを押下するとスワイプした日記項目を削除する() async {
        
        let diariesState: IdentifiedArray<UUID, DiaryListItemFeature.State> = [
            DiaryListItemFeature.State(.create())
        ]
        
        let viewState = DiaryListFeature.State.ViewState(hasDiaryItems: true)
        let deleteAlert: AlertState<DiaryListFeature.Action.Alert> = .createAlertStateWithCancel(
            .deleteDiaryItemConfirmAlert,
            firstButtonHandler: .confirmDeleteItem(deleteItemId: diariesState[0].id)
        )
        let store = TestStore(
            initialState: DiaryListFeature.State(alert: deleteAlert,
                                                 filteredDiaries: diariesState,
                                                 diaries: diariesState,
                                                 viewState: viewState)) {
                
            DiaryListFeature()
        }
        
        // 実行
        
        await store.send(.alert(.presented(.confirmDeleteItem(deleteItemId: diariesState[0].id)))) {
            
            // 検証
            $0.alert = nil
        }
        
        await store.receive(\.deletedDiaryItem) {
            
            $0.diaries = .init(uniqueElements: [])
            $0.filteredDiaries = .init(uniqueElements: [])
            $0.viewState.hasDiaryItems = false
        }
    }
    
    func test_日記項目の左スワイプで編集ボタンを押下すると編集確認アラートが表示される() async throws {
        
        let diariesState: IdentifiedArray<UUID, DiaryListItemFeature.State> = [
            DiaryListItemFeature.State(.create()),
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
    }
    
    func test_編集確認アラートで編集するボタンを押下すると編集画面へ遷移する() async throws {
        
        let diariesState: IdentifiedArray<UUID, DiaryListItemFeature.State> = [
            DiaryListItemFeature.State(.create()),
         ]
        let alert: AlertState<DiaryListFeature.Action.Alert> = .createAlertStateWithCancel(
            .editDiaryItemConfirmAlert,
            firstButtonHandler: .confirmEditItem(targetId: diariesState[0].id)
        )
        let store = TestStore(
            initialState: DiaryListFeature.State(alert: alert,
                                                 filteredDiaries: diariesState,
                                                 diaries: diariesState)) {
                
            DiaryListFeature()
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
    
    func test_日記作成ボタンを押下すると日記作成画面へ遷移する() async throws {
        
        let store = TestStore(
            initialState: DiaryListFeature.State(path: .init())) {
                
            DiaryListFeature()
        }
                
        await store.send(.tappedCreateNewDiaryButton) {
            
            $0.path.append(.createScreen(.init()))
        }
    }
    
    func test_グラフボタン押下でグラフ画面へ遷移する() async throws {
        
        let store = TestStore(
            initialState: DiaryListFeature.State()) {
                
            DiaryListFeature()
        }
                
        await store.send(.tappedGraphButton) {
            
            $0.path.append(.graphScreen(.init()))
        }
    }
    
    func test_フィルターボタンを押下したらフィルター画面を表示する() async throws {
        
        let store = TestStore(initialState: DiaryListFeature.State(),
                              reducer: { DiaryListFeature() })
                
        // フィルターボタンを押下
        await store.send(.tappedFilterButton) {
            
            // フィルター画面を宛先に追加
            $0.destination = .init(childState: .init())
        }
    }
    
    func test_フィルター画面でフィルターの設定を変更したときリスト画面は変更されたフィルターを反映させる() async throws {
        
        // 準備
        
        let initialDiaryItem = DiaryListItemFeature.State(.create())
        let initialFilters = [
            DiaryListFilterItem(target: .achievement,
                                filterItemId: Self.achievementId,
                                value: "達成していない")
        ]
        let testState = DiaryListFeature.State(
            destination: .init(childState: .init(viewState: .init(currentFilters: .init(uniqueElements: [])))),
            filteredDiaries: .init(),
            diaries: .init(uniqueElements: [initialDiaryItem]),
            viewState: .init(hasDiaryItems: false),
            currentFilters: initialFilters
        )
        let store = TestStore(initialState: testState,
                              reducer: { DiaryListFeature() })
        
        // 実行
        
        await store.send(.destination(.presented(.childAction(.delegate(.confirmedFilter([]))))))
        
        // 検証
        
        await store.receive(\.receiveLoadDiaryListFilter) {
            
            $0.currentFilters = []
            $0.filteredDiaries = .init(uniqueElements: [initialDiaryItem])
            $0.viewState.hasDiaryItems = true
        }
    }
    
    func test_グラフ画面で日記が存在しないアラートのボタン押下を検知したら日記作成画面へ遷移する() async throws {
        
        let testStore = TestStore(
            initialState: DiaryListFeature.State(path: .init([.graphScreen(.init())])),
            reducer: { DiaryListFeature() }
        )
        
        guard let targetPathId = testStore.state.path.ids.first else {
            
            XCTFail()
            return
        }
        await testStore.send(.path(.element(id: targetPathId, action: .graphScreen(.delegate(.tappedEmptyDiaryAlertButton))))) {
            
            $0.path = .init([.createScreen(.init())])
        }
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
