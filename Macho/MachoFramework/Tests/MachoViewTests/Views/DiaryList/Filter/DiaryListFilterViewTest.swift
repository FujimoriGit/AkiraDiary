//
//  DiaryListFilterViewTest.swift
//
//
//  Created by 佐藤汰一 on 2024/08/03.
//

import Combine
import ComposableArchitecture
import XCTest

@testable import MachoCore
@testable import MachoView

final class DiaryListFilterViewTest: XCTestCase {
    
    private static let notAchievementId = UUID(DiaryListFilterTarget.achievement.num)
    private static let achievementId = UUID(DiaryListFilterTarget.achievement.num)
    private static let absTrainingId = UUID()
    private static let dumbbellPressTrainingId = UUID()
    private static let fineTagId = UUID()
    private static let rainTagId = UUID()
    
    // DBに保存されているトレーニング種目のリスト
    private static let expectedSelectableTrainingValues: [ConcreteTrainingTypeData] = [
        ConcreteTrainingTypeData(id: absTrainingId, name: "腹筋"),
        ConcreteTrainingTypeData(id: dumbbellPressTrainingId, name: "ダンベルプレス")
    ]
    
    // DBに保存されているタグのリスト
    private static let expectedSelectableTagValues: [ConcreteTrainingTagData] = [
        ConcreteTrainingTagData(id: fineTagId, tagName: "元気"),
        ConcreteTrainingTagData(id: rainTagId, tagName: "雨")
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
    
    // タグ取得処理のMock
    private static let mockTrainingTagClient = TrainingTagClient.getMockClient(expectedFetchList: expectedSelectableTagValues)
    // トレーニング種別取得処理のMock
    private static let mockTrainingTypeClient = TrainingTypeClient.getMockClient(expectedFetchList: expectedSelectableTrainingValues)
    
    // フィルター画面表示時のケース
    @MainActor
    func testAppearView() async throws {
        
        // dismiss確認用のオブジェクト生成
        let isDismissInvoked = LockIsolated(false)
        
        // Viewで受信するフィルターの期待値生成
        let expectedReceiveFilters = IdentifiedArrayOf(uniqueElements: [
            DiaryListFilterItem(target: .achievement, filterItemId: Self.achievementId, value: "達成している"),
            DiaryListFilterItem(target: .trainingType, filterItemId: Self.absTrainingId, value: "腹筋")
        ])
        
        // フィルター取得処理のMock生成
        let mockFilterClient = DiaryListFilterClient.getMockClient(expectedFetchList: [
            ConcreteDiaryListFilterData(id: Self.achievementId.uuidString + String(DiaryListFilterTarget.achievement.num),
                                        filterTarget: DiaryListFilterTarget.achievement.rawValue,
                                        filterId: Self.achievementId,
                                        filterValue: "達成している"),
            ConcreteDiaryListFilterData(id: Self.absTrainingId.uuidString + String(DiaryListFilterTarget.trainingType.num),
                                        filterTarget: DiaryListFilterTarget.trainingType.rawValue,
                                        filterId: Self.absTrainingId,
                                        filterValue: "腹筋")
        ])
        
        let testStore = TestStore(initialState: DiaryListFilterFeature.State()) {
            
            DiaryListFilterFeature()
        } withDependencies: {
            
            $0.diaryListFilterClient = mockFilterClient
            $0.trainingTypeClient = Self.mockTrainingTypeClient
            $0.trainingTagClient = Self.mockTrainingTagClient
            $0.dismiss = DismissEffect { isDismissInvoked.setValue(true) }
        }
        
        await testStore.send(.onAppear)
        await testStore.receive(.receiveFetchSelectableFilterRes(Self.expectedSelectableFilterValues)) {
            
            $0.selectableFilterValues = Self.expectedSelectableFilterValues
        }
        await testStore.receive(.receiveDidChangeFilterItems(expectedReceiveFilters.elements)) {
            
            $0.currentFilters = expectedReceiveFilters
        }
        await testStore.receive(\.startFilterItemsObserver)
        
        await testStore.send(.tappedOutsideArea)
        XCTAssertTrue(isDismissInvoked.value)
    }
    
    // フィルター種別の削除ボタン押下時のケース
    @MainActor
    func testTappedFilterTypeDeleteButton() async throws {
        
        let isDismissInvoked = LockIsolated(false)
        
        let expectedFilters = IdentifiedArrayOf(uniqueElements: [
            DiaryListFilterItem(target: .achievement, filterItemId: Self.achievementId, value: "達成している"),
        ])
        let expectedFiltersData = expectedFilters.elements.map { ConcreteDiaryListFilterData($0) }
        
        let fetchFilters = IdentifiedArrayOf(uniqueElements: [
            DiaryListFilterItem(target: .achievement, filterItemId: Self.achievementId, value: "達成している"),
            DiaryListFilterItem(target: .trainingType, filterItemId: Self.absTrainingId, value: "腹筋"),
            DiaryListFilterItem(target: .trainingType, filterItemId: Self.dumbbellPressTrainingId, value: "ダンベルプレス")
        ])
        
        let deleteFilters = [
            ConcreteDiaryListFilterData(target: .trainingType, filterItemId: Self.absTrainingId, value: "腹筋"),
            ConcreteDiaryListFilterData(target: .trainingType, filterItemId: Self.dumbbellPressTrainingId, value: "ダンベルプレス")
        ]
        
        let testPublisher = PassthroughSubject<[any DiaryListFilterData], Never>()
        
        // フィルター取得処理のMock生成
        let mockFilterClient = DiaryListFilterClient.getMockClient(expectedFetchList: [
            ConcreteDiaryListFilterData(id: Self.achievementId.uuidString + String(DiaryListFilterTarget.achievement.num),
                                        filterTarget: DiaryListFilterTarget.achievement.rawValue,
                                        filterId: Self.achievementId,
                                        filterValue: "達成している"),
            ConcreteDiaryListFilterData(id: Self.absTrainingId.uuidString + String(DiaryListFilterTarget.trainingType.num),
                                        filterTarget: DiaryListFilterTarget.trainingType.rawValue,
                                        filterId: Self.absTrainingId,
                                        filterValue: "腹筋"),
            ConcreteDiaryListFilterData(id: Self.dumbbellPressTrainingId.uuidString + String(DiaryListFilterTarget.trainingType.num),
                                        filterTarget: DiaryListFilterTarget.trainingType.rawValue,
                                        filterId: Self.dumbbellPressTrainingId,
                                        filterValue: "ダンベルプレス")
        ],
                                                                   expectedDeleteFilters: deleteFilters,
                                                                   expectedDeleteFiltersResult: true,
                                                                   stubObserver: testPublisher.eraseToAnyPublisher())
        
        let testStore = TestStore(initialState: DiaryListFilterFeature.State()) {
            
            DiaryListFilterFeature()
        } withDependencies: {
            
            $0.diaryListFilterClient = mockFilterClient
            $0.trainingTypeClient = Self.mockTrainingTypeClient
            $0.trainingTagClient = Self.mockTrainingTagClient
            $0.dismiss = DismissEffect { isDismissInvoked.setValue(true) }
        }
        
        await testStore.send(.onAppear)
        await testStore.receive(\.receiveFetchSelectableFilterRes) {
            
            $0.selectableFilterValues = Self.expectedSelectableFilterValues
        }
        await testStore.receive(\.receiveDidChangeFilterItems) {
            
            $0.currentFilters = fetchFilters
        }
        await testStore.receive(\.startFilterItemsObserver)
        
        await testStore.send(.tappedFilterTypeDeleteButton(target: .trainingType))
        testPublisher.send(expectedFiltersData)
        await testStore.receive(\.receiveDidChangeFilterItems) {
            
            $0.currentFilters = expectedFilters
        }
        
        await testStore.send(.tappedOutsideArea)
        XCTAssertTrue(isDismissInvoked.value)
    }
    
    // フィルター項目の削除ボタン押下時のケース
    @MainActor
    func testTappedFilterItemDeleteButton() async throws {
        
        let isDismissInvoked = LockIsolated(false)
        
        let expectedFilters = IdentifiedArrayOf(uniqueElements: [
            DiaryListFilterItem(target: .achievement, filterItemId: Self.achievementId, value: "達成している"),
            DiaryListFilterItem(target: .trainingType, filterItemId: Self.absTrainingId, value: "腹筋")
        ])
        let expectedFiltersData = [
            ConcreteDiaryListFilterData(target: .achievement, filterItemId: Self.achievementId, value: "達成している"),
            ConcreteDiaryListFilterData(target: .trainingType, filterItemId: Self.absTrainingId, value: "腹筋")
        ]
        
        let fetchFilters = IdentifiedArrayOf(uniqueElements: [
            DiaryListFilterItem(target: .achievement, filterItemId: Self.achievementId, value: "達成している"),
            DiaryListFilterItem(target: .trainingType, filterItemId: Self.absTrainingId, value: "腹筋"),
            DiaryListFilterItem(target: .trainingType, filterItemId: Self.dumbbellPressTrainingId, value: "ダンベルプレス")
        ])
        
        let deleteFilter = DiaryListFilterItem(target: .trainingType, filterItemId: Self.dumbbellPressTrainingId, value: "ダンベルプレス")
        let deleteFilterData = ConcreteDiaryListFilterData(deleteFilter)
        
        
        let testPublisher = PassthroughSubject<[any DiaryListFilterData], Never>()
        
        // フィルター取得処理のMock生成
        let mockFilterClient = DiaryListFilterClient.getMockClient(expectedFetchList: [
            ConcreteDiaryListFilterData(id: Self.achievementId.uuidString + String(DiaryListFilterTarget.achievement.num),
                                        filterTarget: DiaryListFilterTarget.achievement.rawValue,
                                        filterId: Self.achievementId,
                                        filterValue: "達成している"),
            ConcreteDiaryListFilterData(id: Self.absTrainingId.uuidString + String(DiaryListFilterTarget.trainingType.num),
                                        filterTarget: DiaryListFilterTarget.trainingType.rawValue,
                                        filterId: Self.absTrainingId,
                                        filterValue: "腹筋"),
            ConcreteDiaryListFilterData(id: Self.dumbbellPressTrainingId.uuidString + String(DiaryListFilterTarget.trainingType.num),
                                        filterTarget: DiaryListFilterTarget.trainingType.rawValue,
                                        filterId: Self.dumbbellPressTrainingId,
                                        filterValue: "ダンベルプレス")
        ],
                                                                   expectedDeleteFilters: [deleteFilterData],
                                                                   expectedDeleteFiltersResult: true,
                                                                   stubObserver: testPublisher.eraseToAnyPublisher())
        
        let testStore = TestStore(initialState: DiaryListFilterFeature.State()) {
            
            DiaryListFilterFeature()
        } withDependencies: {
            
            $0.diaryListFilterClient = mockFilterClient
            $0.trainingTypeClient = Self.mockTrainingTypeClient
            $0.trainingTagClient = Self.mockTrainingTagClient
            $0.dismiss = DismissEffect { isDismissInvoked.setValue(true) }
        }
        
        await testStore.send(.onAppear)
        await testStore.receive(\.receiveFetchSelectableFilterRes) {
            
            $0.selectableFilterValues = Self.expectedSelectableFilterValues
        }
        await testStore.receive(\.receiveDidChangeFilterItems) {
            
            $0.currentFilters = fetchFilters
        }
        await testStore.receive(\.startFilterItemsObserver)
        
        await testStore.send(.tappedFilterItemDeleteButton(filter: deleteFilter))
        testPublisher.send(expectedFiltersData)
        await testStore.receive(\.receiveDidChangeFilterItems) {
            
            $0.currentFilters = expectedFilters
        }
        
        await testStore.send(.tappedOutsideArea)
        XCTAssertTrue(isDismissInvoked.value)
    }
    
    // フィルターメニュー項目のボタン押下時のケース(フィルターが追加される)
    @MainActor
    func testTappedFilterMenuItemButton() async throws {
        
        let isDismissInvoked = LockIsolated(false)
        
        let addFilter = DiaryListFilterItem(target: .trainingType, filterItemId: Self.dumbbellPressTrainingId, value: "ダンベルプレス")
        let addFilterData = ConcreteDiaryListFilterData(addFilter)
        let updateFilter = DiaryListFilterItem(target: .achievement, filterItemId: Self.achievementId, value: "達成していない")
        let updateFilterData = ConcreteDiaryListFilterData(target: .achievement, filterItemId: Self.achievementId, value: "達成していない")
        
        let addedExpectedFilters = IdentifiedArrayOf(uniqueElements: [
            DiaryListFilterItem(target: .achievement, filterItemId: Self.achievementId, value: "達成している"),
            DiaryListFilterItem(target: .trainingType, filterItemId: Self.absTrainingId, value: "腹筋"),
            DiaryListFilterItem(target: .trainingType, filterItemId: Self.dumbbellPressTrainingId, value: "ダンベルプレス")
        ])
        
        let addedExpectedFiltersData = [
            ConcreteDiaryListFilterData(target: .achievement, filterItemId: Self.achievementId, value: "達成している"),
            ConcreteDiaryListFilterData(target: .trainingType, filterItemId: Self.absTrainingId, value: "腹筋"),
            ConcreteDiaryListFilterData(target: .trainingType, filterItemId: Self.dumbbellPressTrainingId, value: "ダンベルプレス")
        ]
        
        let updatedExpectedFilters = IdentifiedArrayOf(uniqueElements: [
            DiaryListFilterItem(target: .achievement, filterItemId: Self.achievementId, value: "達成していない"),
            DiaryListFilterItem(target: .trainingType, filterItemId: Self.absTrainingId, value: "腹筋"),
            DiaryListFilterItem(target: .trainingType, filterItemId: Self.dumbbellPressTrainingId, value: "ダンベルプレス")
        ])
        
        let updatedExpectedFiltersData = [
            ConcreteDiaryListFilterData(target: .achievement, filterItemId: Self.achievementId, value: "達成していない"),
            ConcreteDiaryListFilterData(target: .trainingType, filterItemId: Self.absTrainingId, value: "腹筋"),
            ConcreteDiaryListFilterData(target: .trainingType, filterItemId: Self.dumbbellPressTrainingId, value: "ダンベルプレス")
        ]
        
        let fetchFilters = IdentifiedArrayOf(uniqueElements: [
            DiaryListFilterItem(target: .achievement, filterItemId: Self.achievementId, value: "達成している"),
            DiaryListFilterItem(target: .trainingType, filterItemId: Self.absTrainingId, value: "腹筋"),
        ])
        
        let testPublisher = PassthroughSubject<[any DiaryListFilterData], Never>()
        
        // フィルター取得処理のMock生成
        let mockFilterClient = DiaryListFilterClient.getMockClient(expectedFetchList: [
            ConcreteDiaryListFilterData(id: Self.achievementId.uuidString + String(DiaryListFilterTarget.achievement.num),
                                        filterTarget: DiaryListFilterTarget.achievement.rawValue,
                                        filterId: Self.achievementId,
                                        filterValue: "達成している"),
            ConcreteDiaryListFilterData(id: Self.absTrainingId.uuidString + String(DiaryListFilterTarget.trainingType.num),
                                        filterTarget: DiaryListFilterTarget.trainingType.rawValue,
                                        filterId: Self.absTrainingId,
                                        filterValue: "腹筋")
        ],
                                                                   expectedAddFilter: addFilterData,
                                                                   expectedAddFilterResult: true,
                                                                   expectedDeleteFiltersResult: true, stubObserver: testPublisher.eraseToAnyPublisher())
        
        let testStore = TestStore(initialState: DiaryListFilterFeature.State()) {
            
            DiaryListFilterFeature()
        } withDependencies: {
            
            $0.diaryListFilterClient = mockFilterClient
            $0.trainingTypeClient = Self.mockTrainingTypeClient
            $0.trainingTagClient = Self.mockTrainingTagClient
            $0.dismiss = DismissEffect { isDismissInvoked.setValue(true) }
        }
        
        await testStore.send(.onAppear)
        await testStore.receive(.receiveFetchSelectableFilterRes(Self.expectedSelectableFilterValues)) {
            
            $0.selectableFilterValues = Self.expectedSelectableFilterValues
        }
        await testStore.receive(\.receiveDidChangeFilterItems) {
            
            $0.currentFilters = fetchFilters
        }
        await testStore.receive(\.startFilterItemsObserver)
        
        await testStore.send(.tappedFilterMenuItem(filter: addFilter))
        testPublisher.send(addedExpectedFiltersData)
        await testStore.receive(\.receiveDidChangeFilterItems) {
            
            $0.currentFilters = addedExpectedFilters
        }
        
        await testStore.send(.tappedFilterMenuItem(filter: addFilter))
        
        testStore.dependencies.diaryListFilterClient.addFilter =
        DiaryListFilterClient.addFilterMock(expectedAddFilter: updateFilterData,
                                            expectedAddFilterResult: true)
        await testStore.send(.tappedFilterMenuItem(filter: updateFilter))
        testPublisher.send(updatedExpectedFiltersData)
        await testStore.receive(\.receiveDidChangeFilterItems) {
            
            $0.currentFilters = updatedExpectedFilters
        }
        
        await testStore.send(.tappedFilterMenuItem(filter: updateFilter))
        
        await testStore.send(.tappedCloseButton)
        XCTAssertTrue(isDismissInvoked.value)
    }
}
