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
@testable import MachoCore
@testable import RealmHelper

@MainActor
struct AddTagViewTest {

    @Test
    func タグ保存ボタン押下で入力しているタグ名のタグを登録する() async throws {
        
        let dismissInvoke = LockIsolated(false)
        
        let trainingTagClient = try await TrainingTagClient.getMockClient(
            realm: RealmTestHelper.getMockRealm(),
            initialValue: []
        )
        
        let testStore = TestStore(initialState: .init(
            tagName: TrainingTagData.unfine.tagName,
            isEnableSaveButton: true
        ),
                                  reducer: { AddTagFeature() }) {
            
            $0.trainingTagClient = trainingTagClient
            $0.dismiss = .init { dismissInvoke.setValue(true) }
            $0.uuid = .init { TrainingTagData.unfine.id }
        }
        
        await testStore.send(.saveButtonTapped)
        await testStore.finish()
        
        #expect(dismissInvoke.value)
        
        let resultTagList = await trainingTagClient.fetchAll()
        #expect([.unfine] == resultTagList)
    }
    
    @Test
    func すでに存在するタグ名が入力されている状態でタグ保存ボタン押下すると保存に失敗する() async throws {
        
        let dismissInvoke = LockIsolated(false)
        let expectedValue: [TrainingTagData] = [.fine]
        
        let trainingTagClient = try await TrainingTagClient.getMockClient(
            realm: RealmTestHelper.getMockRealm(),
            initialValue: expectedValue
        )
        
        let testStore = TestStore(initialState: .init(
            tagName: expectedValue.first!.tagName,
            isEnableSaveButton: true
        ),
                                  reducer: { AddTagFeature() }) {
            
            $0.trainingTagClient = trainingTagClient
            $0.dismiss = .init { dismissInvoke.setValue(true) }
        }
        
        await testStore.send(.saveButtonTapped)
        
        #expect(dismissInvoke.value)
        
        let actualValue = await trainingTagClient.fetchAll()
        #expect(actualValue == expectedValue)
    }
}
