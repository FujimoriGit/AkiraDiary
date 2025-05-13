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
    private static let trainingId = UUID(DiaryListFilterTarget.achievement.num)
    
    // DBに保存されているトレーニング種目のリスト
    private static let expectedSelectableTrainingValues: [TrainingTypeData] = [
        .abs,
        .benchPress
    ]
    
    // DBに保存されているタグのリスト
    private static let expectedSelectableTagValues: [TrainingTagData] = [
        .fine,
        .unfine
    ]
    
    // 設定可能フィルターの期待値
    private static let expectedSelectableFilterValues: [DiaryListFilterItem] = [
        DiaryListFilterItem(target: .achievement, filterItemId: notAchievementId, value: "達成していない"),
        DiaryListFilterItem(target: .achievement, filterItemId: achievementId, value: "達成している"),
        DiaryListFilterItem(target: .achievement, filterItemId: trainingId, value: "トレーニング中"),
        DiaryListFilterItem(target: .trainingType,
                            filterItemId: TrainingTypeData.abs.id,
                            value: TrainingTypeData.abs.name),
        DiaryListFilterItem(target: .trainingType,
                            filterItemId: TrainingTypeData.benchPress.id,
                            value: TrainingTypeData.benchPress.name),
        DiaryListFilterItem(target: .tag,
                            filterItemId: TrainingTagData.fine.id,
                            value: TrainingTagData.fine.tagName),
        DiaryListFilterItem(target: .tag,
                            filterItemId: TrainingTagData.unfine.id,
                            value: TrainingTagData.unfine.tagName)
    ]
    
    func test_画面表示時選択可能なフィルターと現在適用されているフィルターを画面に反映させる() async throws {
        
        // Viewで受信するフィルターの期待値生成
        let expectedReceiveFilters = IdentifiedArrayOf(uniqueElements: [
            Self.expectedSelectableFilterValues[1],
            Self.expectedSelectableFilterValues[3]
        ])
        
        let mockRealm = try await RealmTestHelper.getMockRealm()
        let mockFilterClient = await DiaryListFilterClient.getMockClient(
            realm: mockRealm,
            initialValue: DiaryListFilterDataConverter.convertToDiaryListFilterDataList(expectedReceiveFilters.elements)
        )
        let mockTypeClient = await buildMockTrainingTypeClient(realm: mockRealm)
        let mockTagClient = await buildMockTrainingTagClient(realm: mockRealm)
        
        let testStore = TestStore(initialState: DiaryListFilterFeature.State()) {
            
            DiaryListFilterFeature()
        } withDependencies: {
            
            $0.diaryListFilterClient = mockFilterClient
            $0.trainingTypeClient = mockTypeClient
            $0.trainingTagClient = mockTagClient
            $0.dismiss = DismissEffect {}
        }
        
        // 実行
        
        await testStore.send(.onAppear)
        await testStore.receive(\.receiveFetchSelectableFilterRes) {
            
            $0.selectableFilterValues = Self.expectedSelectableFilterValues
        }
        await testStore.receive(\.startObserve)
        await testStore.receive(\.receiveDidChangeFilterItems) {
            
            $0.currentFilters = expectedReceiveFilters
        }
        
        // 後始末
        
        await cleaningForEndOfTest(testStore)
    }
    
    func test_閉じるボタンを押下すると現在設定しているフィルターを親画面に伝えて画面を閉じる() async throws {
                
        let settingFilters = IdentifiedArrayOf(uniqueElements: [
            Self.expectedSelectableFilterValues[1],
            Self.expectedSelectableFilterValues[3]
        ])
        
        let testStore = TestStore(initialState: .init(viewState: .init(currentFilters: settingFilters))) {
            
            DiaryListFilterFeature()
        }
        
        // 実行
        
        await testStore.send(.tappedCloseButton)
        
        // 検証
        
        await testStore.receive(\.willDismiss)
        await testStore.receive(.delegate(.confirmedFilter(settingFilters.elements)))
    }
    
    // フィルター種別の削除ボタン押下時のケース
    func test_フィルター種別の削除ボタンを押下すると選択したフィルター種別に該当するフィルター項目を全て未選択状態にする() async throws {
        
        let allFilter = IdentifiedArrayOf(uniqueElements: [
            Self.expectedSelectableFilterValues[1],
            Self.expectedSelectableFilterValues[3],
            Self.expectedSelectableFilterValues[4]
        ])
        
        let expectedFilters = IdentifiedArrayOf(uniqueElements: [
            Self.expectedSelectableFilterValues[1]
        ])
        
        let mockRealm = try await RealmTestHelper.getMockRealm()
        
        let testStore = await setupTestStoreWithBeforeAppeared(
            mockRealm: mockRealm,
            initialFilters: allFilter
        )
        
        // 実行
        
        await testStore.send(.tappedFilterTypeDeleteButton(target: .trainingType))
        
        // 検証
        
        await testStore.receive(\.receiveDidChangeFilterItems) {
            
            $0.currentFilters = expectedFilters
        }
        
        // 後始末
        
        await cleaningForEndOfTest(testStore)
    }
    
    func test_フィルター項目の削除ボタン押下で選択したフィルター項目を未選択状態にする() async throws {
                
        let allFilter = IdentifiedArrayOf(uniqueElements: [
            Self.expectedSelectableFilterValues[1],
            Self.expectedSelectableFilterValues[3],
            Self.expectedSelectableFilterValues[4]
        ])
        
        let expectedFilters = IdentifiedArrayOf(uniqueElements: [
            Self.expectedSelectableFilterValues[1],
            Self.expectedSelectableFilterValues[3]
        ])
        
        let mockRealm = try await RealmTestHelper.getMockRealm()
        let testStore = await setupTestStoreWithBeforeAppeared(
            mockRealm: mockRealm,
            initialFilters: allFilter
        )
        
        // 実行
        
        let deleteFilter = Self.expectedSelectableFilterValues[4]
        await testStore.send(.tappedFilterItemDeleteButton(filter: deleteFilter))
        await testStore.receive(\.receiveDidChangeFilterItems) {
            
            $0.currentFilters = expectedFilters
        }
        
        // 後始末
        
        await cleaningForEndOfTest(testStore)
    }
    
    func test_複数選択可能なフィルターのメニューからフィルター項目を選択するとそのフィルター項目を適用状態にする() async throws {
        
        let allFilter = IdentifiedArrayOf(uniqueElements: [
            Self.expectedSelectableFilterValues[1],
            Self.expectedSelectableFilterValues[3]
        ])
        
        let expectedFilters = IdentifiedArrayOf(uniqueElements: [
            Self.expectedSelectableFilterValues[1],
            Self.expectedSelectableFilterValues[3],
            Self.expectedSelectableFilterValues[4]
        ])

        let mockRealm = try await RealmTestHelper.getMockRealm()
        let testStore = await setupTestStoreWithBeforeAppeared(
            mockRealm: mockRealm,
            initialFilters: allFilter
        )
        
        // 実行
        
        let addFilter = Self.expectedSelectableFilterValues[4]
        await testStore.send(.tappedFilterMenuItem(filter: addFilter))
        await testStore.receive(\.receiveDidChangeFilterItems) {
            
            $0.currentFilters = expectedFilters
        }
                
        // 後始末
        
        await cleaningForEndOfTest(testStore)
    }
    
    func test_単一選択可能なフィルター種別のメニューからフィルター項目を選択するとフィルター項目の値を選択した値に更新する() async throws {
        
        let allFilter = IdentifiedArrayOf(uniqueElements: [
            Self.expectedSelectableFilterValues[1]
        ])
        
        let expectedFilters = IdentifiedArrayOf(uniqueElements: [
            Self.expectedSelectableFilterValues[0]
        ])
        
        
        let mockRealm = try await RealmTestHelper.getMockRealm()
        let testStore = await setupTestStoreWithBeforeAppeared(
            mockRealm: mockRealm,
            initialFilters: allFilter
        )
        
        // 実行
        
        let updateFilter = Self.expectedSelectableFilterValues[0]
        await testStore.send(.tappedFilterMenuItem(filter: updateFilter))
        await testStore.receive(\.receiveDidChangeFilterItems) {
            
            $0.currentFilters = expectedFilters
        }
        
        // 後始末
        
        await cleaningForEndOfTest(testStore)
    }
}

private extension DiaryListFilterViewTest {
    
    // タグ取得処理のMock
    private func buildMockTrainingTagClient(realm: RealmWrapper) async -> TrainingTagClient {
        
        return await TrainingTagClient.getMockClient(
            realm: realm,
            initialValue: Self.expectedSelectableTagValues
        )
    }
    
    // トレーニング種別取得処理のMock
    private func buildMockTrainingTypeClient(realm: RealmWrapper) async -> TrainingTypeClient {
        
        return await TrainingTypeClient.getMockClient(
            realm: realm,
            initialValue: Self.expectedSelectableTrainingValues
        )
    }
    
    func cleaningForEndOfTest(_ testStore: TestStoreOf<DiaryListFilterFeature>) async {
        
        await testStore.send(.tappedCloseButton)
        await testStore.receive(\.willDismiss)
        await testStore.receive(\.delegate)
        await testStore.finish()
    }
    
    // 画面表示後のTestStoreをセットアップする
    func setupTestStoreWithBeforeAppeared(mockRealm: RealmWrapper,
                                          initialFilters: IdentifiedArrayOf<DiaryListFilterItem>) async -> TestStoreOf<DiaryListFilterFeature> {
        
        let diaryFilterClientMock = await DiaryListFilterClient.getMockClient(
            realm: mockRealm,
            initialValue: DiaryListFilterDataConverter.convertToDiaryListFilterDataList(initialFilters.elements)
        )
        let trainingTypeClientMock = await buildMockTrainingTypeClient(realm: mockRealm)
        let trainingTagClientMock = await buildMockTrainingTagClient(realm: mockRealm)
        let testStore = TestStore(initialState: DiaryListFilterFeature.State()) {
            
            DiaryListFilterFeature()
        } withDependencies: {
            
            $0.diaryListFilterClient = diaryFilterClientMock
            $0.trainingTypeClient = trainingTypeClientMock
            $0.trainingTagClient = trainingTagClientMock
        }
        
        await testStore.send(.onAppear)
        await testStore.receive(\.receiveFetchSelectableFilterRes) {
            
            $0.selectableFilterValues = Self.expectedSelectableFilterValues
        }
        await testStore.receive(\.startObserve)
        await testStore.receive(\.receiveDidChangeFilterItems) {
            
            $0.currentFilters = initialFilters
        }
        
        return testStore
    }
}
