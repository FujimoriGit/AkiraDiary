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
        
        let testStore = TestStore(initialState: .init(isFocusedTextField: .title),
                                  reducer: { DiaryCreationFeature() })
        
        await testStore.send(.tappedOutsideOfKeyboard) {
            
            $0.isFocusedTextField = nil
        }
    }
    
    @Test
    func テキストフィールドをタップした場合タップしたテキストフィールドにフォーカスする() async throws {
        
        let testStore = TestStore(initialState: .init(),
                                  reducer: { DiaryCreationFeature() })
        
        await testStore.send(.didChangeFocusState(.title)) {
            
            $0.isFocusedTextField = .title
        }
    }

}
