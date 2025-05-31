//
//  MachoFramework
//
//  DiaryCreationViewTest.swift
//
//  Created by stotic-dev on 2025/03/09
//  Copyright © Macho All rights reserved.
//

import ComposableArchitecture
import Testing

@testable import MachoView

@MainActor
struct DiaryCreationViewTest {

    @Test
    func キーボード表示中にキーボード領域外をタップするとキーボードを閉じる() async throws {
        
        let testStore = TestStore(initialState: .init(textFieldFocusState: .title),
                                  reducer: { DiaryCreationFeature() })
        
        await testStore.send(.tappedOutsideOfKeyboard) {
            
            $0.textFieldFocusState = nil
        }
    }
    
    @Test
    func テキストフィールドをタップした場合タップしたテキストフィールドにフォーカスする() async throws {
        
        let testStore = TestStore(initialState: .init(),
                                  reducer: { DiaryCreationFeature() })
        
        await testStore.send(.didChangeFocusState(.title)) {
            
            $0.textFieldFocusState = .title
        }
    }

    @Test
    func 戻るボタンを押下すると入力情報が消えることを確認するアラートを表示する() async throws {
        
        let testStore = TestStore(initialState: .init(),
                                  reducer: { DiaryCreationFeature() })
        
        await testStore.send(.tappedNavigationBackButton) {
            
            $0.alert = .createAlertStateWithCancel(.confirmNoSavingDiary,
                                                   firstButtonHandler: .tappedDismissAcceptButton)
        }
    }
    
    @Test
    func 入力情報が消えることを確認するアラートでOKボタン押下すると前画面に戻る() async throws {
        
        let dismissInvoke = LockIsolated(false)
        let testStore = TestStore(initialState: .init(
            alert: .createAlertStateWithCancel(
                .confirmNoSavingDiary,
                firstButtonHandler: .tappedDismissAcceptButton
            )
        ),
                                  reducer: { DiaryCreationFeature() }) {
            
            $0.dismiss = .init { dismissInvoke.setValue(true) }
        }
        
        await testStore.send(.alert(.presented(.tappedDismissAcceptButton))) {
            
            $0.alert = nil
        }
        
        #expect(dismissInvoke.value)
    }
}
