//
//  DiaryListFilterViewTest.swift
//
//
//  Created by 佐藤汰一 on 2024/08/03.
//

import Combine
import ComposableArchitecture
import RealmHelper
import XCTest

@testable import MachoView

@MainActor
final class DiaryListFilterViewTest: XCTestCase {
    
    private static let notAchievementId = UUID(DiaryListFilterTarget.achievement.num)
    private static let achievementId = UUID(DiaryListFilterTarget.achievement.num)
    private static let trainingId = UUID(DiaryListFilterTarget.achievement.num)
    
    // DBに保存されているトレーニング種目のリスト
    private static let expectedSelectableTrainingValues: [TrainingTypeEntity] = [
        .abs,
        .benchPress
    ]
    
    // DBに保存されているタグのリスト
    private static let expectedSelectableTagValues: [TrainingTagEntity] = [
        .fine,
        .unfine
    ]
    
    // 設定可能フィルターの期待値
    private static let expectedSelectableFilterValues: [DiaryListFilterItem] = [
        DiaryListFilterItem(target: .achievement, filterItemId: notAchievementId, value: "達成していない"),
        DiaryListFilterItem(target: .achievement, filterItemId: achievementId, value: "達成している"),
        DiaryListFilterItem(target: .achievement, filterItemId: trainingId, value: "トレーニング中"),
        DiaryListFilterItem(target: .trainingType,
                            filterItemId: TrainingTypeEntity.abs.id,
                            value: TrainingTypeEntity.abs.name),
        DiaryListFilterItem(target: .trainingType,
                            filterItemId: TrainingTypeEntity.benchPress.id,
                            value: TrainingTypeEntity.benchPress.name),
        DiaryListFilterItem(target: .tag,
                            filterItemId: TrainingTagEntity.fine.id,
                            value: TrainingTagEntity.fine.tagName),
        DiaryListFilterItem(target: .tag,
                            filterItemId: TrainingTagEntity.unfine.id,
                            value: TrainingTagEntity.unfine.tagName)
    ]
    
    // DBからのタグ取得をモックしたRealm
    private static let tagMockRealm = RealmAccessorMock(fetchEntity: expectedSelectableTagValues)
    // DBからのトレーニング種別取得をモックしたRealm
    private static let trainingTypeMockRealm = RealmAccessorMock(fetchEntity: expectedSelectableTrainingValues)
    
    func test_画面表示時選択可能なフィルターと現在適用されているフィルターを画面に反映させる() async throws {
        
        // Viewで受信するフィルターの期待値生成
        let expectedReceiveFilters = IdentifiedArrayOf(uniqueElements: [
            Self.expectedSelectableFilterValues[1],
            Self.expectedSelectableFilterValues[3]
        ])
        
        let mockRealm = RealmAccessorMock(fetchEntity: expectedReceiveFilters.elements.map(\.entity))
        let testStore = TestStore(initialState: DiaryListFilterFeature.State()) {
            
            DiaryListFilterFeature()
        } withDependencies: {
            
            $0.diaryListFilterApi = .createCustomValue(mockRealm)
            $0.trainingTypeApi = .createCustomValue(Self.trainingTypeMockRealm)
            $0.trainingTagApi = .createCustomValue(Self.tagMockRealm)
            $0.dismiss = DismissEffect {}
        }
        
        // 実行
        
        await testStore.send(.onAppear)
        await testStore.receive(\.receiveFetchSelectableFilterRes) {
            
            $0.selectableFilterValues = Self.expectedSelectableFilterValues
        }
        await testStore.receive(.receiveDidChangeFilterItems(expectedReceiveFilters.elements)) {
            
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
        
        let testPublisher = PassthroughSubject<[DiaryListFilterItem], Never>()
        let mockRealm = RealmAccessorMock<DiaryListFilterData>(
            fetchEntity: allFilter.elements.map(\.entity),
            expectedDeleteResult: {
            
            // 削除後のフィルターリストをPublisherに送信
            testPublisher.send(expectedFilters.elements)
            return true
        })
        
        let testStore = await setupTestStoreWithBeforeAppeared(
            mockFilterApi: .createCustomValue(mockRealm) { testPublisher.eraseToAnyPublisher() },
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
        
        let testPublisher = PassthroughSubject<[DiaryListFilterItem], Never>()
        let mockRealm = RealmAccessorMock<DiaryListFilterData>(
            fetchEntity: allFilter.elements.map { .init(id: $0.id, filterTarget: $0.target.rawValue, filterId: $0.filterItemId, filterValue: $0.value) },
            expectedDeleteResult: {
            
            // 削除後のフィルターリストをPublisherに送信
            testPublisher.send(expectedFilters.elements)
            return true
        })
        
        let testStore = await setupTestStoreWithBeforeAppeared(
            mockFilterApi: .createCustomValue(mockRealm) { testPublisher.eraseToAnyPublisher() },
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

        let testPublisher = PassthroughSubject<[DiaryListFilterItem], Never>()
        let mockRealm = RealmAccessorMock<DiaryListFilterData>(
            fetchEntity: allFilter.elements.map { .init(id: $0.id, filterTarget: $0.target.rawValue, filterId: $0.filterItemId, filterValue: $0.value) },
            expectedInsertResult: { _ in
                
                testPublisher.send(expectedFilters.elements)
                return true
            })
        
        let testStore = await setupTestStoreWithBeforeAppeared(
            mockFilterApi: .createCustomValue(mockRealm) { testPublisher.eraseToAnyPublisher() },
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
        
        let testPublisher = PassthroughSubject<[DiaryListFilterItem], Never>()
        let mockRealm = RealmAccessorMock<DiaryListFilterData>(
            fetchEntity: allFilter.elements.map { .init(id: $0.id, filterTarget: $0.target.rawValue, filterId: $0.filterItemId, filterValue: $0.value) },
            expectedUpdateResult: { _, _ in
                
                testPublisher.send(expectedFilters.elements)
                return true
            })
        
        let testStore = await setupTestStoreWithBeforeAppeared(
            mockFilterApi: .createCustomValue(mockRealm) { testPublisher.eraseToAnyPublisher() },
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
    
    func cleaningForEndOfTest(_ testStore: TestStoreOf<DiaryListFilterFeature>) async {
        
        await testStore.send(.tappedCloseButton)
        await testStore.receive(\.willDismiss)
        await testStore.receive(\.delegate)
    }
    
    // 画面表示後のTestStoreをセットアップする
    func setupTestStoreWithBeforeAppeared(mockFilterApi: DiaryListFilterClient,
                                          initialFilters: IdentifiedArrayOf<DiaryListFilterItem>) async -> TestStoreOf<DiaryListFilterFeature> {
        
        let testStore = TestStore(initialState: DiaryListFilterFeature.State()) {
            
            DiaryListFilterFeature()
        } withDependencies: {
            
            $0.diaryListFilterApi = mockFilterApi
            $0.trainingTypeApi = .createCustomValue(Self.trainingTypeMockRealm)
            $0.trainingTagApi = .createCustomValue(Self.tagMockRealm)
        }
        
        await testStore.send(.onAppear)
        await testStore.receive(\.receiveFetchSelectableFilterRes) {
            
            $0.selectableFilterValues = Self.expectedSelectableFilterValues
        }
        await testStore.receive(\.receiveDidChangeFilterItems) {
            
            $0.currentFilters = initialFilters
        }
        
        return testStore
    }
}

fileprivate extension DiaryListFilterItem {
    
    var entity: DiaryListFilterData {
        
        return .init(id: id,
                     filterTarget: target.rawValue,
                     filterId: filterItemId,
                     filterValue: value)
    }
}
