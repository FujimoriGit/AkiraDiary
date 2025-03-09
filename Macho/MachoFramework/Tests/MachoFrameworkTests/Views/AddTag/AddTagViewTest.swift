//
//  MachoFramework
//
//  AddTagViewTest.swift
//
//  Created by stotic-dev on 2025/03/09
//  Copyright © Macho All rights reserved.
//

import ComposableArchitecture
import Foundation
import Testing

@testable import MachoView

@MainActor
struct AddTagViewTest {

    @Test
    func タグ保存ボタン押下で入力しているタグ名のタグを登録する() async throws {
        
        let dismissInvoke = LockIsolated(false)
        
        let mockRealm = RealmAccessorMock(fetchEntity: [
            TrainingTagData.fine
        ])
        
        async let checkAddTag: () = confirmation { confirmation in
            let result = await withCheckedContinuation { continuation in
                mockRealm.expectedInsertResult = { actual in
                    
                    guard let target = try? #require(actual.first) else {
                        
                        continuation.resume(returning: false)
                        return false
                    }
                    #expect(target.tagName == TrainingTagData.unfine.tagName)
                    continuation.resume(returning: true)
                    return true
                }
            }
            
            #expect(result)
            confirmation()
        }
        
        let testStore = TestStore(initialState: .init(
            tagName: TrainingTagData.unfine.tagName,
            isEnableSaveButton: true
        ),
                                  reducer: { AddTagFeature() }) {
            
            $0.trainingTagApi = TrainingTagClient.createCustomValue(mockRealm)
            $0.dismiss = .init { dismissInvoke.setValue(true) }
        }
        
        await testStore.send(.saveButtonTapped)
        
        await checkAddTag
        #expect(dismissInvoke.value)
    }
    
    @Test
    func すでに存在するタグ名が入力されている状態でタグ保存ボタン押下すると保存に失敗する() async throws {
        
        let dismissInvoke = LockIsolated(false)
        
        let mockRealm = RealmAccessorMock(fetchEntity: [
            TrainingTagData.fine
        ]) { _ in
            
            Issue.record()
            return false
        }
        let testStore = TestStore(initialState: .init(
            tagName: TrainingTagData.fine.tagName,
            isEnableSaveButton: true
        ),
                                  reducer: { AddTagFeature() }) {
            
            $0.trainingTagApi = TrainingTagClient.createCustomValue(mockRealm)
            $0.dismiss = .init { dismissInvoke.setValue(true) }
        }
        
        await testStore.send(.saveButtonTapped)
        
        #expect(dismissInvoke.value)
    }
}
