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
    
    // フィルターID
    private static let achievementId = UUID(DiaryListFilterTarget.achievement.num)
    
    func test_日記リストが下にバウンスした時ぐるぐるを表示して古い日記を取得する() async throws {
        
        let initialDiary = DiaryListItemFeature.State(.create(date: .distantFuture))
        let expectedAddedItem = DiaryListItemFeature.State(.create(date: .distantPast))
        let expectedLoadedDiaries = DiaryList(elements: [
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
        let mockDiaryClient = try await DiaryEntityClient.getMockClient(
            realm: RealmTestHelper.getMockRealm(),
            initialValue: expectedLoadedDiaries.elements.map { .init($0.diary) }
        )
        let store = TestStore(
            initialState: DiaryListFeature.State(
                diaryList: .init(elements: [initialDiary]),
                trackableList: trackableListState,
                viewState: viewState
            ), reducer: { DiaryListFeature() }) {
                
                $0.diaryEntityClient = mockDiaryClient
            }
                
        // 300pxスクロールして下にバウンスが発生
        await store.send(.trackableList(TrackableListFeature.Action.onScroll(offset: -300))) {
            
            $0.trackableList.offset = -300
            $0.viewState.isScrolling = true
            $0.viewState.isLoadingDiaries = true
        }
        
        await store.receive(\.receiveLoadDiaryItems) {
            
            $0.viewState.isLoadingDiaries = false
            $0.diaryList = expectedLoadedDiaries
            $0.filteredDiaries = .init(uniqueElements: expectedLoadedDiaries.elements)
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
                diaryList: .init(elements: [.init(.create())]),
                trackableList: trackableListState,
                viewState: viewState),
            reducer: { DiaryListFeature() })
        
        // 上にスクロールして一番上の画面に戻る
        await store.send(.trackableList(TrackableListFeature.Action.onScroll(offset: 0))) {
            
            $0.trackableList.offset = 0
            $0.viewState.isScrolling = false
        }
    }
    
    func test_画面表示時に前回のフィルター内容でフィルタリングした日記リストを表示する() async throws {
        
        let expectedItem = DiaryListItemFeature.State(.create(goals: [.create(isAchieved: false)],
                                                              endTime: Date()))
        let receivedFilters = [DiaryListFilterItem(target: .achievement, filterItemId: Self.achievementId, value: "達成していない")]
        
        let mockRealm = try await RealmTestHelper.getMockRealm()
        let mockDiaryListClient = await DiaryEntityClient.getMockClient(
            realm: mockRealm,
            initialValue: [.init(expectedItem.diary)]
        )
        let mockDiaryFilterClient = await DiaryListFilterClient.getMockClient(
            realm: mockRealm,
            initialValue: DiaryListFilterDataConverter.convertToDiaryListFilterDataList(receivedFilters)
        )
        let store = TestStore(initialState: DiaryListFeature.State(),
                              reducer: { DiaryListFeature() }) {
            
            $0.diaryEntityClient = mockDiaryListClient
            $0.diaryListFilterClient = mockDiaryFilterClient
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
            
            $0.diaryList = .init(elements: [expectedItem])
            $0.filteredDiaries = [expectedItem]
            $0.viewState.isLoadingDiaries = false
            $0.viewState.hasDiaryItems = true
        }
    }
    
    func test_日記作成画面で日記追加後に日記リストに戻ったら追加した日記をリストに表示する() async throws {
        
        let initialFirstItem = DiaryListItemFeature.State(.create(
            date: .create(year: 2025, month: 2, day: 1))
        )
        let fetchedNewItem = DiaryListItemFeature.State(.create(
            date: .create(year: 2025, month: 1, day: 1))
        )
        
        let mockRealm = try await RealmTestHelper.getMockRealm()
        let mockDiaryListClient = await DiaryEntityClient.getMockClient(
            realm: mockRealm,
            initialValue: [
                .init(initialFirstItem.diary),
                .init(fetchedNewItem.diary)]
        )
        let mockDiaryFilterClient = await DiaryListFilterClient.getMockClient(
            realm: mockRealm,
            initialValue: []
        )
        let store = TestStore(
            initialState: DiaryListFeature.State(
                filteredDiaries: .init(uniqueElements: [initialFirstItem]),
                diaryList: .init(elements: [initialFirstItem]),
                viewState: .init(hasDiaryItems: true)
            ),
            reducer: { DiaryListFeature() }
        ) {
            
            $0.diaryEntityClient = mockDiaryListClient
            $0.diaryListFilterClient = mockDiaryFilterClient
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
            $0.diaryList = .init(elements: expectedLoadedDiaries.elements)
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
            initialState: DiaryListFeature.State(
                filteredDiaries: diariesState,
                diaryList: .init(elements: diariesState.elements)
            )) {
                
                DiaryListFeature()
            }
        
        // 日記リストのセルタップ時の動作
        await store.send(.diaries(.element(id: diariesState[0].id, action: .tappedDiaryItem))) {
            
            // 編集画面をナビゲーションスタックに追加
            $0.path.append(.detailScreen(.init(diary: diariesState.first!.diary)))
        }
    }
    
    func test_日記項目の左スワイプで削除ボタンを押下すると削除確認アラートを表示する() async throws {
        
        let diariesState: IdentifiedArray<UUID, DiaryListItemFeature.State> = [
            DiaryListItemFeature.State(.create()),
         ]
        
        let viewState = DiaryListFeature.State.ViewState(hasDiaryItems: true)
        
        let mockRealm = try await RealmTestHelper.getMockRealm()
        let mockDiaryClient = await DiaryEntityClient.getMockClient(
            realm: mockRealm,
            initialValue: diariesState.elements.map { .init($0.diary) }
        )
        
        let store = TestStore(
            initialState: DiaryListFeature.State(
                filteredDiaries: diariesState,
                diaryList: .init(elements: diariesState.elements),
                viewState: viewState
            )) {
                
                DiaryListFeature()
            } withDependencies: {
                
                $0.diaryEntityClient = mockDiaryClient
            }
        
        // 削除確認アラートの表示
        await store.send(.diaries(.element(id: diariesState[0].id, action: .deleteItemSwipeAction))) {
            
            $0.alert = AlertState.createAlertStateWithCancel(.deleteDiaryItemConfirmAlert,
                                                             firstButtonHandler: .confirmDeleteItem(deleteItemId: diariesState[0].id))
        }
    }
    
    func test_削除確認アラートで削除するボタンを押下するとスワイプした日記項目を削除する() async throws {
        
        let diariesState: IdentifiedArray<UUID, DiaryListItemFeature.State> = [
            DiaryListItemFeature.State(.create())
        ]
        
        let viewState = DiaryListFeature.State.ViewState(hasDiaryItems: true)
        let deleteAlert: AlertState<DiaryListFeature.Action.Alert> = .createAlertStateWithCancel(
            .deleteDiaryItemConfirmAlert,
            firstButtonHandler: .confirmDeleteItem(deleteItemId: diariesState[0].id)
        )
        let mockDiaryClient = try await DiaryEntityClient.getMockClient(
            realm: RealmTestHelper.getMockRealm(),
            initialValue: diariesState.map { .init($0.diary) }
        )
        let store = TestStore(
            initialState: DiaryListFeature.State(
                alert: deleteAlert,
                filteredDiaries: diariesState,
                diaryList: .init(elements: diariesState.elements),
                viewState: viewState
            )) {
                
            DiaryListFeature()
            } withDependencies: {
                
                $0.diaryEntityClient = mockDiaryClient
            }
        
        // 実行
        
        await store.send(.alert(.presented(.confirmDeleteItem(deleteItemId: diariesState[0].id)))) {
            
            // 検証
            $0.alert = nil
        }
        
        await store.receive(\.deletedDiaryItem) {
            
            $0.diaryList = .init(elements: [])
            $0.filteredDiaries = .init(uniqueElements: [])
            $0.viewState.hasDiaryItems = false
        }
    }
    
    func test_日記項目の左スワイプで編集ボタンを押下すると編集確認アラートが表示される() async throws {
        
        let diariesState: IdentifiedArray<UUID, DiaryListItemFeature.State> = [
            DiaryListItemFeature.State(.create()),
         ]
        
        let store = TestStore(
            initialState: DiaryListFeature.State(
                filteredDiaries: diariesState,
                diaryList: .init(elements: diariesState.elements)
            )) {
                
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
            initialState: DiaryListFeature.State(
                alert: alert,
                filteredDiaries: diariesState,
                diaryList: .init(elements: diariesState.elements)
            )) {
                
            DiaryListFeature()
        }
                
        await store.send(.alert(.presented(.confirmEditItem(targetId: diariesState[0].id)))) {
            
            $0.alert = nil
            $0.path.append(.editScreen(.init(editTarget: diariesState[0].diary)))
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
            diaryList: .init(elements: [initialDiaryItem]),
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
