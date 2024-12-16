//
//  PopUpViewTest.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/12/16.
//

import ComposableArchitecture
import XCTest

@testable import MachoView

@MainActor
final class PopUpViewTest: XCTestCase {
    
    func testTappedBackground() async throws {
        
        let dismissInvoke = LockIsolated(false)
        
        let testStore = TestStore(initialState: .init(childState: SelectTrainingTypeContentFeature.State(selectingTrainingTypeList: [])),
                                  reducer: { PopUpFeature<SelectTrainingTypeContentFeature>() }) {
            
            $0.dismiss = DismissEffect { dismissInvoke.setValue(true) }
        }
        
        // 画面表示
        await testStore.send(.onAppear) {
            
            $0.isShowing = true
        }
        
        // バックグラウンドタップで画面非表示
        await testStore.send(.tappedBackground)
        
        await testStore.receive(.childAction(.willDismissAction)) {
            
            $0.isShowing = false
        }
        
        await testStore.receive(\.childAction.delegate)
        
        try await Task.sleep(for: .seconds(1.5))
        
        // dismissしたことを確認
        XCTAssertTrue(dismissInvoke.value)
    }
}
