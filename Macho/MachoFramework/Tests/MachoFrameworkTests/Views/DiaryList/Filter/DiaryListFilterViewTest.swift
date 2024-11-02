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

final class DiaryListFilterViewTest: XCTestCase {
    
    private static let notAchievementId = UUID(DiaryListFilterTarget.achievement.num)
    private static let achievementId = UUID(DiaryListFilterTarget.achievement.num)
    private static let absTrainingId = UUID()
    private static let dumbbellPressTrainingId = UUID()
    private static let fineTagId = UUID()
    private static let rainTagId = UUID()
    
    // DBに保存されているトレーニング種目のリスト
    private static let expectedSelectableTrainingValues: [TrainingTypeEntity] = [
        TrainingTypeEntity(id: absTrainingId, name: "腹筋"),
        TrainingTypeEntity(id: dumbbellPressTrainingId, name: "ダンベルプレス")
    ]
    
    // DBに保存されているタグのリスト
    private static let expectedSelectableTagValues: [TrainingTagEntity] = [
        TrainingTagEntity(id: fineTagId, tagName: "元気"),
        TrainingTagEntity(id: rainTagId, tagName: "雨")
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
    
    // DBからのタグ取得をモックしたRealm
    private static let tagMockRealm = RealmAccessorMock(fetchEntity: expectedSelectableTagValues)
    // DBからのトレーニング種別取得をモックしたRealm
    private static let trainingTypeMockRealm = RealmAccessorMock(fetchEntity: expectedSelectableTrainingValues)
    
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
        
        // realmのモックオブジェクト生成
        let mockRealm = RealmAccessorMock(fetchEntity: [
            DiaryListFilterEntity(id: Self.achievementId.uuidString + String(DiaryListFilterTarget.achievement.num),
                                  filterTarget: DiaryListFilterTarget.achievement.rawValue,
                                  filterId: Self.achievementId,
                                  filterValue: "達成している"),
            DiaryListFilterEntity(id: Self.absTrainingId.uuidString + String(DiaryListFilterTarget.trainingType.num),
                                  filterTarget: DiaryListFilterTarget.trainingType.rawValue,
                                  filterId: Self.absTrainingId,
                                  filterValue: "腹筋")
        ])
        
        let testStore = TestStore(initialState: DiaryListFilterFeature.State()) {
            
            DiaryListFilterFeature()
        } withDependencies: {
            
            $0.diaryListFilterApi = .createCustomValue(mockRealm)
            $0.trainingTypeApi = .createCustomValue(Self.trainingTypeMockRealm)
            $0.trainingTagApi = .createCustomValue(Self.tagMockRealm)
            $0.dismiss = DismissEffect { isDismissInvoked.setValue(true) }
        }
        
        await testStore.send(.onAppear)
        await testStore.receive(.receiveFetchSelectableFilterRes(Self.expectedSelectableFilterValues)) {
            
            $0.selectableFilterValues = Self.expectedSelectableFilterValues
        }
        await testStore.receive(.receiveDidChangeFilterItems(expectedReceiveFilters.elements)) {
            
            $0.currentFilters = expectedReceiveFilters
        }
        
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
        
        let fetchFilters = IdentifiedArrayOf(uniqueElements: [
            DiaryListFilterItem(target: .achievement, filterItemId: Self.achievementId, value: "達成している"),
            DiaryListFilterItem(target: .trainingType, filterItemId: Self.absTrainingId, value: "腹筋"),
            DiaryListFilterItem(target: .trainingType, filterItemId: Self.dumbbellPressTrainingId, value: "ダンベルプレス")
        ])
        
        let testPublisher = PassthroughSubject<[DiaryListFilterItem], Never>()
        
        // realmのモックオブジェクト生成
        let mockRealm = RealmAccessorMock(fetchEntity: [
            DiaryListFilterEntity(id: Self.achievementId.uuidString + String(DiaryListFilterTarget.achievement.num),
                                  filterTarget: DiaryListFilterTarget.achievement.rawValue,
                                  filterId: Self.achievementId,
                                  filterValue: "達成している"),
            DiaryListFilterEntity(id: Self.absTrainingId.uuidString + String(DiaryListFilterTarget.trainingType.num),
                                  filterTarget: DiaryListFilterTarget.trainingType.rawValue,
                                  filterId: Self.absTrainingId,
                                  filterValue: "腹筋"),
            DiaryListFilterEntity(id: Self.dumbbellPressTrainingId.uuidString + String(DiaryListFilterTarget.trainingType.num),
                                  filterTarget: DiaryListFilterTarget.trainingType.rawValue,
                                  filterId: Self.dumbbellPressTrainingId,
                                  filterValue: "ダンベルプレス")
        ], expectedDeleteResult: {
            
            // 削除後のフィルターリストをPublisherに送信
            testPublisher.send(expectedFilters.elements)
            return true
        })
        
        let testStore = TestStore(initialState: DiaryListFilterFeature.State()) {
            
            DiaryListFilterFeature()
        } withDependencies: {
            
            $0.diaryListFilterApi = .createCustomValue(mockRealm) { testPublisher.eraseToAnyPublisher() }
            $0.trainingTypeApi = .createCustomValue(Self.trainingTypeMockRealm)
            $0.trainingTagApi = .createCustomValue(Self.tagMockRealm)
            $0.dismiss = DismissEffect { isDismissInvoked.setValue(true) }
        }
        
        await testStore.send(.onAppear)
        await testStore.receive(.receiveFetchSelectableFilterRes(Self.expectedSelectableFilterValues)) {
            
            $0.selectableFilterValues = Self.expectedSelectableFilterValues
        }
        await testStore.receive(.receiveDidChangeFilterItems(fetchFilters.map { $0 })) {
            
            $0.currentFilters = fetchFilters
        }
        
        await testStore.send(.tappedFilterTypeDeleteButton(target: .trainingType))
        
        await testStore.receive(.receiveDidChangeFilterItems(expectedFilters.map { $0 })) {
            
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
        
        let fetchFilters = IdentifiedArrayOf(uniqueElements: [
            DiaryListFilterItem(target: .achievement, filterItemId: Self.achievementId, value: "達成している"),
            DiaryListFilterItem(target: .trainingType, filterItemId: Self.absTrainingId, value: "腹筋"),
            DiaryListFilterItem(target: .trainingType, filterItemId: Self.dumbbellPressTrainingId, value: "ダンベルプレス")
        ])
        
        let deleteFilter = DiaryListFilterItem(target: .trainingType, filterItemId: Self.dumbbellPressTrainingId, value: "ダンベルプレス")
        
        let testPublisher = PassthroughSubject<[DiaryListFilterItem], Never>()
        
        // realmのモックオブジェクト生成
        let mockRealm = RealmAccessorMock(fetchEntity: [
            DiaryListFilterEntity(id: Self.achievementId.uuidString + String(DiaryListFilterTarget.achievement.num),
                                  filterTarget: DiaryListFilterTarget.achievement.rawValue,
                                  filterId: Self.achievementId,
                                  filterValue: "達成している"),
            DiaryListFilterEntity(id: Self.absTrainingId.uuidString + String(DiaryListFilterTarget.trainingType.num),
                                  filterTarget: DiaryListFilterTarget.trainingType.rawValue,
                                  filterId: Self.absTrainingId,
                                  filterValue: "腹筋"),
            DiaryListFilterEntity(id: Self.dumbbellPressTrainingId.uuidString + String(DiaryListFilterTarget.trainingType.num),
                                  filterTarget: DiaryListFilterTarget.trainingType.rawValue,
                                  filterId: Self.dumbbellPressTrainingId,
                                  filterValue: "ダンベルプレス")
        ], expectedDeleteResult: {
            
            // 削除後のフィルターリストをPublisherに送信
            testPublisher.send(expectedFilters.elements)
            return true
        })
        
        let testStore = TestStore(initialState: DiaryListFilterFeature.State()) {
            
            DiaryListFilterFeature()
        } withDependencies: {
            
            $0.diaryListFilterApi = .createCustomValue(mockRealm) { testPublisher.eraseToAnyPublisher() }
            $0.trainingTypeApi = .createCustomValue(Self.trainingTypeMockRealm)
            $0.trainingTagApi = .createCustomValue(Self.tagMockRealm)
            $0.dismiss = DismissEffect { isDismissInvoked.setValue(true) }
        }
        
        await testStore.send(.onAppear)
        await testStore.receive(.receiveFetchSelectableFilterRes(Self.expectedSelectableFilterValues)) {
            
            $0.selectableFilterValues = Self.expectedSelectableFilterValues
        }
        await testStore.receive(.receiveDidChangeFilterItems(fetchFilters.map { $0 })) {
            
            $0.currentFilters = fetchFilters
        }
        
        await testStore.send(.tappedFilterItemDeleteButton(filter: deleteFilter))
        
        await testStore.receive(.receiveDidChangeFilterItems(expectedFilters.map { $0 })) {
            
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
        let updateFilter = DiaryListFilterItem(target: .achievement, filterItemId: Self.achievementId, value: "達成していない")
        
        let addedExpectedFilters = IdentifiedArrayOf(uniqueElements: [
            DiaryListFilterItem(target: .achievement, filterItemId: Self.achievementId, value: "達成している"),
            DiaryListFilterItem(target: .trainingType, filterItemId: Self.absTrainingId, value: "腹筋"),
            DiaryListFilterItem(target: .trainingType, filterItemId: Self.dumbbellPressTrainingId, value: "ダンベルプレス")
        ])
        
        let updatedExpectedFilters = IdentifiedArrayOf(uniqueElements: [
            DiaryListFilterItem(target: .achievement, filterItemId: Self.achievementId, value: "達成していない"),
            DiaryListFilterItem(target: .trainingType, filterItemId: Self.absTrainingId, value: "腹筋"),
            DiaryListFilterItem(target: .trainingType, filterItemId: Self.dumbbellPressTrainingId, value: "ダンベルプレス")
        ])
        
        let fetchFilters = IdentifiedArrayOf(uniqueElements: [
            DiaryListFilterItem(target: .achievement, filterItemId: Self.achievementId, value: "達成している"),
            DiaryListFilterItem(target: .trainingType, filterItemId: Self.absTrainingId, value: "腹筋"),
        ])
        
        let testPublisher = PassthroughSubject<[DiaryListFilterItem], Never>()
        
        // realmのモックオブジェクト生成
        let mockRealm = RealmAccessorMock(fetchEntity: [
            DiaryListFilterEntity(id: Self.achievementId.uuidString + String(DiaryListFilterTarget.achievement.num),
                                  filterTarget: DiaryListFilterTarget.achievement.rawValue,
                                  filterId: Self.achievementId,
                                  filterValue: "達成している"),
            DiaryListFilterEntity(id: Self.absTrainingId.uuidString + String(DiaryListFilterTarget.trainingType.num),
                                  filterTarget: DiaryListFilterTarget.trainingType.rawValue,
                                  filterId: Self.absTrainingId,
                                  filterValue: "腹筋")
        ], expectedInsertResult: { _ in
            
            testPublisher.send(addedExpectedFilters.elements)
            return true
        }, expectedUpdateResult: { _, _ in
            
            testPublisher.send(updatedExpectedFilters.elements)
            return true
        })
        
        let testStore = TestStore(initialState: DiaryListFilterFeature.State()) {
            
            DiaryListFilterFeature()
        } withDependencies: {
            
            $0.diaryListFilterApi = .createCustomValue(mockRealm) { testPublisher.eraseToAnyPublisher() }
            $0.trainingTypeApi = .createCustomValue(Self.trainingTypeMockRealm)
            $0.trainingTagApi = .createCustomValue(Self.tagMockRealm)
            $0.dismiss = DismissEffect { isDismissInvoked.setValue(true) }
        }
        
        await testStore.send(.onAppear)
        await testStore.receive(.receiveFetchSelectableFilterRes(Self.expectedSelectableFilterValues)) {
            
            $0.selectableFilterValues = Self.expectedSelectableFilterValues
        }
        await testStore.receive(.receiveDidChangeFilterItems(fetchFilters.map { $0 })) {
            
            $0.currentFilters = fetchFilters
        }
        
        await testStore.send(.tappedFilterMenuItem(filter: addFilter))
        await testStore.receive(.receiveDidChangeFilterItems(addedExpectedFilters.map { $0 })) {
            
            $0.currentFilters = addedExpectedFilters
        }
        
        await testStore.send(.tappedFilterMenuItem(filter: addFilter))
        
        await testStore.send(.tappedFilterMenuItem(filter: updateFilter))
        await testStore.receive(.receiveDidChangeFilterItems(updatedExpectedFilters.map { $0 })) {
            
            $0.currentFilters = updatedExpectedFilters
        }
        
        await testStore.send(.tappedFilterMenuItem(filter: updateFilter))
        
        await testStore.send(.tappedCloseButton)
        XCTAssertTrue(isDismissInvoked.value)
    }
}
