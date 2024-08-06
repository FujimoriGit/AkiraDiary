//
//  DiaryListFilterViewTest.swift
//
//
//  Created by 佐藤汰一 on 2024/08/03.
//

import Combine
import ComposableArchitecture
import XCTest

@testable import MachoView

final class DiaryListFilterViewTest: XCTestCase {

    // フィルター画面表示時のケース
    @MainActor
    func testAppearView() async throws {
        
        let expectedReceiveFilters = IdentifiedArrayOf(uniqueElements: [DiaryListFilterItem(target: .achievement, value: "aaaa"),
                                                                        DiaryListFilterItem(target: .trainingType, value: "bbbb")])
        
        let testStore = TestStore(initialState: DiaryListFilterFeature.State()) {
            DiaryListFilterFeature()
        } withDependencies: {
            $0.diaryListFilterApi = DiaryListFilterClient(addFilter: { _ in
                
                return true
            }, deleteFilters: { _ in
                
                return true
            }, fetchFilterList: {
                
                return expectedReceiveFilters.elements
            }, getFilterListObserver: {
                
                return PassthroughSubject<[DiaryListFilterItem], Never>().eraseToAnyPublisher()
            })
        }
        
        await testStore.send(.onAppear)
        await testStore.receive(.receiveDidChangeFilterItems(expectedReceiveFilters.elements)) {
            
            $0.currentFilters = expectedReceiveFilters
        }
        
        await testStore.send(.onDisappear)
    }
    
    // ダイアログ外の領域タップのケース
    @MainActor
    func testTappedOutsideArea() async throws {
        
        let isDismissInvoked = LockIsolated(false)
        
        let testStore = TestStore(initialState: DiaryListFilterFeature.State()) {
            DiaryListFilterFeature()
        } withDependencies: {
            $0.dismiss = DismissEffect { isDismissInvoked.setValue(true) }
        }
        
        await testStore.send(.tappedOutsideArea)
        XCTAssertTrue(isDismissInvoked.value)
    }
    
    // クローズボタン押下時のケース
    @MainActor
    func testTappedCloseButton() async throws {
        
        let isDismissInvoked = LockIsolated(false)
        
        let testStore = TestStore(initialState: DiaryListFilterFeature.State()) {
            DiaryListFilterFeature()
        } withDependencies: {
            $0.dismiss = DismissEffect { isDismissInvoked.setValue(true) }
        }
        
        await testStore.send(.tappedCloseButton)
        XCTAssertTrue(isDismissInvoked.value)
    }
    
    // フィルター種別の削除ボタン押下時のケース
    @MainActor
    func testTappedFilterTypeDeleteButton() async throws {
        
        let expectedFilters = IdentifiedArrayOf(uniqueElements: [DiaryListFilterItem(target: .achievement, value: "aaaa")])
        
        let fetchFilters = IdentifiedArrayOf(uniqueElements: [DiaryListFilterItem(target: .achievement, value: "aaaa"),
                                                              DiaryListFilterItem(target: .trainingType, value: "bbbb"),
                                                              DiaryListFilterItem(target: .trainingType, value: "cccc")])
        
        let testPublisher = PassthroughSubject<[DiaryListFilterItem], Never>()
        
        let testStore = TestStore(initialState: DiaryListFilterFeature.State()) {
            
            DiaryListFilterFeature()
        } withDependencies: {
            
            $0.diaryListFilterApi = DiaryListFilterClient(addFilter: { _ in
                
                return true
            }, deleteFilters: { _ in
                
                return true
            }, fetchFilterList: {
                
                return fetchFilters.elements
            }, getFilterListObserver: {
                
                return testPublisher.eraseToAnyPublisher()
            })
        }
        
        await testStore.send(.onAppear)
        await testStore.receive(.receiveDidChangeFilterItems(fetchFilters.map { $0 })) {
            
            $0.currentFilters = fetchFilters
        }
        
        await testStore.send(.tappedFilterTypeDeleteButton(.trainingType))
        
        testPublisher.send(expectedFilters.elements)
        
        await testStore.receive(.receiveDidChangeFilterItems(expectedFilters.map { $0 })) {
            
            $0.currentFilters = expectedFilters
        }
        
        await testStore.send(.onDisappear)
    }
    
    // フィルター項目の削除ボタン押下時のケース
    @MainActor
    func testTappedFilterItemDeleteButton() async throws {
        
        let expectedFilters = IdentifiedArrayOf(uniqueElements: [DiaryListFilterItem(target: .achievement, value: "aaaa"),
                                                                 DiaryListFilterItem(target: .trainingType, value: "bbbb")])
        
        let fetchFilters = IdentifiedArrayOf(uniqueElements: [DiaryListFilterItem(target: .achievement, value: "aaaa"),
                                                              DiaryListFilterItem(target: .trainingType, value: "bbbb"),
                                                              DiaryListFilterItem(target: .trainingType, value: "cccc")])
        
        let deleteItem = DiaryListFilterItem(target: .trainingType, value: "cccc")
        
        let testPublisher = PassthroughSubject<[DiaryListFilterItem], Never>()
        
        let testStore = TestStore(initialState: DiaryListFilterFeature.State()) {
            
            DiaryListFilterFeature()
        } withDependencies: {
            
            $0.diaryListFilterApi = DiaryListFilterClient(addFilter: { _ in
                
                return true
            }, deleteFilters: { _ in
                
                return true
            }, fetchFilterList: {
                
                return fetchFilters.elements
            }, getFilterListObserver: {
                
                return testPublisher.eraseToAnyPublisher()
            })
        }
        
        await testStore.send(.onAppear)
        await testStore.receive(.receiveDidChangeFilterItems(fetchFilters.map { $0 })) {
            
            $0.currentFilters = fetchFilters
        }
        
        await testStore.send(.tappedFilterItemDeleteButton(deleteItem))
        
        testPublisher.send(expectedFilters.elements)
        
        await testStore.receive(.receiveDidChangeFilterItems(expectedFilters.map { $0 })) {
            
            $0.currentFilters = expectedFilters
        }
        
        await testStore.send(.onDisappear)
    }
    
    // フィルターメニュー項目のボタン押下時のケース(フィルターが追加される)
    @MainActor
    func testTappedFilterMenuItemButton() async throws {
        
        let expectedFilters = IdentifiedArrayOf(uniqueElements: [DiaryListFilterItem(target: .achievement, value: "aaaa"),
                                                                 DiaryListFilterItem(target: .trainingType, value: "bbbb"),
                                                                 DiaryListFilterItem(target: .trainingType, value: "cccc")])
        
        let fetchFilters = IdentifiedArrayOf(uniqueElements: [DiaryListFilterItem(target: .achievement, value: "aaaa"),
                                                              DiaryListFilterItem(target: .trainingType, value: "bbbb")])
        
        let addItem = DiaryListFilterItem(target: .trainingType, value: "cccc")
        
        let testPublisher = PassthroughSubject<[DiaryListFilterItem], Never>()
        
        let testStore = TestStore(initialState: DiaryListFilterFeature.State()) {
            
            DiaryListFilterFeature()
        } withDependencies: {
            
            $0.diaryListFilterApi = DiaryListFilterClient(addFilter: { _ in
                
                return true
            }, deleteFilters: { _ in
                
                return true
            }, fetchFilterList: {
                
                return fetchFilters.elements
            }, getFilterListObserver: {
                
                return testPublisher.eraseToAnyPublisher()
            })
        }
        
        await testStore.send(.onAppear)
        await testStore.receive(.receiveDidChangeFilterItems(fetchFilters.map { $0 })) {
            
            $0.currentFilters = fetchFilters
        }
        
        await testStore.send(.tappedFilterMenuItem(addItem))
        
        testPublisher.send(expectedFilters.elements)
        
        await testStore.receive(.receiveDidChangeFilterItems(expectedFilters.map { $0 })) {
            
            $0.currentFilters = expectedFilters
        }
        
        await testStore.send(.onDisappear)
    }
}
