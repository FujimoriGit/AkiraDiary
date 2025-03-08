//
//  DiaryListFilterViewTest.swift
//
//
//  Created by 佐藤汰一 on 2024/08/03.
//

import ComposableArchitecture
import XCTest

@testable import MachoCore
@testable import MachoView
@testable import RealmHelper

@MainActor
final class DiaryListFilterViewTest: XCTestCase {
    
    private static let notAchievementId = UUID(DiaryListFilterTarget.achievement.num)
    private static let achievementId = UUID(DiaryListFilterTarget.achievement.num)
    private static let absTrainingId = UUID()
    private static let dumbbellPressTrainingId = UUID()
    private static let fineTagId = UUID()
    private static let rainTagId = UUID()
    
    // DBに保存されているトレーニング種目のリスト
    private static let expectedSelectableTrainingValues: [TrainingTypeData] = [
        TrainingTypeData(id: absTrainingId, name: "腹筋"),
        TrainingTypeData(id: dumbbellPressTrainingId, name: "ダンベルプレス")
    ]
    
    // DBに保存されているタグのリスト
    private static let expectedSelectableTagValues: [TrainingTagData] = [
        TrainingTagData(id: fineTagId, tagName: "元気"),
        TrainingTagData(id: rainTagId, tagName: "雨")
    ]
    
    // 設定可能フィルターの期待値
    private static let expectedSelectableFilterValues: [DiaryListFilterItem] = [
        DiaryListFilterItem(target: .achievement, filterItemId: notAchievementId, value: "達成していない"),
        DiaryListFilterItem(target: .achievement, filterItemId: achievementId, value: "達成している"),
        DiaryListFilterItem(target: .trainingType, filterItemId: absTrainingId, value: "腹筋"),
        DiaryListFilterItem(target: .trainingType, filterItemId: dumbbellPressTrainingId, value: "ダンベルプレス"),
        DiaryListFilterItem(target: .tag, filterItemId: fineTagId, value: "元気"),
        DiaryListFilterItem(target: .tag, filterItemId: rainTagId, value: "雨")
    ]
    
    // フィルター画面表示時のケース
    func testAppearView() async throws {
        
        // dismiss確認用のオブジェクト生成
        let isDismissInvoked = LockIsolated(false)
        
        // Viewで受信するフィルターの期待値生成
        let inputFilters = [
            DiaryListFilterData(target: .achievement, filterItemId: Self.achievementId, value: "達成している"),
            DiaryListFilterData(target: .trainingType, filterItemId: Self.absTrainingId, value: "腹筋")
        ]
        
        let mockRealm = try await RealmTestHelper.getMockRealm()
        let mockFilterClient = DiaryListFilterClient.getMockClient(realm: mockRealm)
        let mockTypeClient = await buildMockTrainingTypeClient(realm: mockRealm)
        let mockTagClient = await buildMockTrainingTagClient(realm: mockRealm)
        await RealmTestHelper.setupDiaryFilterList(mockFilterClient, filterList: inputFilters)
        
        let testStore = TestStore(initialState: DiaryListFilterFeature.State()) {
            
            DiaryListFilterFeature()
        } withDependencies: {
            
            $0.diaryListFilterClient = mockFilterClient
            $0.trainingTypeClient = mockTypeClient
            $0.trainingTagClient = mockTagClient
            $0.dismiss = DismissEffect { isDismissInvoked.setValue(true) }
        }
        
        await testStore.send(.onAppear)
        await testStore.receive(.receiveFetchSelectableFilterRes(Self.expectedSelectableFilterValues)) {
            
            $0.selectableFilterValues = Self.expectedSelectableFilterValues
        }
        await testStore.receive(\.startFilterItemsObserver)
        
        await testStore.receive(\.receiveDidChangeFilterItems) {
            
            $0.currentFilters = .init(uniqueElements: inputFilters.map { .init(entity: $0) })
        }
        
        await testStore.send(.tappedOutsideArea)
        XCTAssertTrue(isDismissInvoked.value)
    }
    
    // フィルター種別の削除ボタン押下時のケース
    func testTappedFilterTypeDeleteButton() async throws {
        
        let isDismissInvoked = LockIsolated(false)
        
        let inputFilters = [
            DiaryListFilterData(target: .achievement, filterItemId: Self.achievementId, value: "達成している"),
            DiaryListFilterData(target: .trainingType, filterItemId: Self.absTrainingId, value: "腹筋"),
            DiaryListFilterData(target: .trainingType, filterItemId: Self.dumbbellPressTrainingId, value: "ダンベルプレス")
        ]
        
        let mockRealm = try await RealmTestHelper.getMockRealm()
        let mockFilterClient = DiaryListFilterClient.getMockClient(realm: mockRealm)
        let mockTypeClient = await buildMockTrainingTypeClient(realm: mockRealm)
        let mockTagClient = await buildMockTrainingTagClient(realm: mockRealm)
        await RealmTestHelper.setupDiaryFilterList(mockFilterClient, filterList: inputFilters)
        
        let testStore = TestStore(initialState: DiaryListFilterFeature.State()) {
            
            DiaryListFilterFeature()
        } withDependencies: {
            
            $0.diaryListFilterClient = mockFilterClient
            $0.trainingTypeClient = mockTypeClient
            $0.trainingTagClient = mockTagClient
            $0.dismiss = DismissEffect { isDismissInvoked.setValue(true) }
        }
        
        await testStore.send(.onAppear)
        await testStore.receive(\.receiveFetchSelectableFilterRes) {
            
            $0.selectableFilterValues = Self.expectedSelectableFilterValues
        }
        
        await testStore.receive(\.startFilterItemsObserver)
        await testStore.receive(\.receiveDidChangeFilterItems) {
            
            $0.currentFilters = .init(uniqueElements: inputFilters.map { .init(entity: $0) })
        }
        
        await testStore.send(.tappedFilterTypeDeleteButton(target: .trainingType))
        await testStore.receive(\.receiveDidChangeFilterItems) {
            
            $0.currentFilters = .init(uniqueElements: [
                .init(target: .achievement, filterItemId: Self.achievementId, value: "達成している"),
            ])
        }
        
        await testStore.send(.tappedOutsideArea)
        XCTAssertTrue(isDismissInvoked.value)
    }
    
    // フィルター項目の削除ボタン押下時のケース
    func testTappedFilterItemDeleteButton() async throws {
        
        let isDismissInvoked = LockIsolated(false)
        
        let inputFilters = [
            DiaryListFilterData(target: .achievement, filterItemId: Self.achievementId, value: "達成している"),
            DiaryListFilterData(target: .trainingType, filterItemId: Self.absTrainingId, value: "腹筋"),
            DiaryListFilterData(target: .trainingType, filterItemId: Self.dumbbellPressTrainingId, value: "ダンベルプレス")
        ]
        
        let mockRealm = try await RealmTestHelper.getMockRealm()
        let mockFilterClient = DiaryListFilterClient.getMockClient(realm: mockRealm)
        let mockTypeClient = await buildMockTrainingTypeClient(realm: mockRealm)
        let mockTagClient = await buildMockTrainingTagClient(realm: mockRealm)
        await RealmTestHelper.setupDiaryFilterList(mockFilterClient, filterList: inputFilters)
        
        let testStore = TestStore(initialState: DiaryListFilterFeature.State()) {
            
            DiaryListFilterFeature()
        } withDependencies: {
            
            $0.diaryListFilterClient = mockFilterClient
            $0.trainingTypeClient = mockTypeClient
            $0.trainingTagClient = mockTagClient
            $0.dismiss = DismissEffect { isDismissInvoked.setValue(true) }
        }
        
        await testStore.send(.onAppear)
        await testStore.receive(\.receiveFetchSelectableFilterRes) {
            
            $0.selectableFilterValues = Self.expectedSelectableFilterValues
        }
        
        await testStore.receive(\.startFilterItemsObserver)
        await testStore.receive(\.receiveDidChangeFilterItems) {
            
            $0.currentFilters = .init(uniqueElements: inputFilters.map { .init(entity: $0) })
        }
        
        let deleteFilter = DiaryListFilterItem(target: .trainingType, filterItemId: Self.dumbbellPressTrainingId, value: "ダンベルプレス")
        await testStore.send(.tappedFilterItemDeleteButton(filter: deleteFilter))
        await testStore.receive(\.receiveDidChangeFilterItems) {
            
            $0.currentFilters = .init(uniqueElements: [
                DiaryListFilterItem(target: .achievement, filterItemId: Self.achievementId, value: "達成している"),
                DiaryListFilterItem(target: .trainingType, filterItemId: Self.absTrainingId, value: "腹筋")
            ])
        }
        
        await testStore.send(.tappedOutsideArea)
        XCTAssertTrue(isDismissInvoked.value)
    }
    
    // フィルターメニュー項目のボタン押下時のケース(フィルターが追加される)
    func testTappedFilterMenuItemButton() async throws {
        
        let isDismissInvoked = LockIsolated(false)
        
        let inputFilters = [
            DiaryListFilterData(target: .achievement, filterItemId: Self.achievementId, value: "達成している"),
            DiaryListFilterData(target: .trainingType, filterItemId: Self.absTrainingId, value: "腹筋"),
        ]
        
        let mockRealm = try await RealmTestHelper.getMockRealm()
        let mockFilterClient = DiaryListFilterClient.getMockClient(realm: mockRealm)
        let mockTypeClient = await buildMockTrainingTypeClient(realm: mockRealm)
        let mockTagClient = await buildMockTrainingTagClient(realm: mockRealm)
        await RealmTestHelper.setupDiaryFilterList(mockFilterClient, filterList: inputFilters)
        
        let testStore = TestStore(initialState: DiaryListFilterFeature.State()) {
            
            DiaryListFilterFeature()
        } withDependencies: {
            
            $0.diaryListFilterClient = mockFilterClient
            $0.trainingTypeClient = mockTypeClient
            $0.trainingTagClient = mockTagClient
            $0.dismiss = DismissEffect { isDismissInvoked.setValue(true) }
        }
        
        await testStore.send(.onAppear)
        await testStore.receive(.receiveFetchSelectableFilterRes(Self.expectedSelectableFilterValues)) {
            
            $0.selectableFilterValues = Self.expectedSelectableFilterValues
        }
        
        await testStore.receive(\.startFilterItemsObserver)
        await testStore.receive(\.receiveDidChangeFilterItems) {
            
            $0.currentFilters = .init(uniqueElements: inputFilters.map { .init(entity: $0) })
        }
        
        let addFilter = DiaryListFilterItem(target: .trainingType, filterItemId: Self.dumbbellPressTrainingId, value: "ダンベルプレス")
        await testStore.send(.tappedFilterMenuItem(filter: addFilter))
        await testStore.receive(\.receiveDidChangeFilterItems) {
            
            let addedExpectedFilters = IdentifiedArrayOf(uniqueElements: [
                DiaryListFilterItem(target: .achievement, filterItemId: Self.achievementId, value: "達成している"),
                DiaryListFilterItem(target: .trainingType, filterItemId: Self.absTrainingId, value: "腹筋"),
                DiaryListFilterItem(target: .trainingType, filterItemId: Self.dumbbellPressTrainingId, value: "ダンベルプレス")
            ])
            $0.currentFilters = addedExpectedFilters
        }
        
        await testStore.send(.tappedFilterMenuItem(filter: addFilter))
        
        let updateFilter = DiaryListFilterItem(target: .achievement, filterItemId: Self.achievementId, value: "達成していない")
        await testStore.send(.tappedFilterMenuItem(filter: updateFilter))
        await testStore.receive(\.receiveDidChangeFilterItems) {
            
            let updatedExpectedFilters = IdentifiedArrayOf(uniqueElements: [
                DiaryListFilterItem(target: .achievement, filterItemId: Self.achievementId, value: "達成していない"),
                DiaryListFilterItem(target: .trainingType, filterItemId: Self.absTrainingId, value: "腹筋"),
                DiaryListFilterItem(target: .trainingType, filterItemId: Self.dumbbellPressTrainingId, value: "ダンベルプレス")
            ])
            $0.currentFilters = updatedExpectedFilters
        }
        
        await testStore.send(.tappedFilterMenuItem(filter: updateFilter))
        
        await testStore.send(.tappedCloseButton)
        XCTAssertTrue(isDismissInvoked.value)
    }
}

private extension DiaryListFilterViewTest {
    
    // タグ取得処理のMock
    private func buildMockTrainingTagClient(realm: RealmWrapper) async -> TrainingTagClient {
        
        let client = TrainingTagClient.getMockClient(realm: realm)
        for tag in Self.expectedSelectableTagValues {
            
            let result = await client.add(tag)
            XCTAssertTrue(result)
        }
        
        return client
    }
    
    // トレーニング種別取得処理のMock
    private func buildMockTrainingTypeClient(realm: RealmWrapper) async -> TrainingTypeClient {
        
        let client = TrainingTypeClient.getMockClient(realm: realm)
        for type in Self.expectedSelectableTrainingValues {
            
            let result = await client.add(type)
            XCTAssertTrue(result)
        }
        
        return client
    }
}
