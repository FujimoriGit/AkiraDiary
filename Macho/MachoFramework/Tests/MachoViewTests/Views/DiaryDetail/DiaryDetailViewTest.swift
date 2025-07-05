//
//  DiaryDetailViewTest.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/10/19.
//

import ComposableArchitecture
import XCTest

@testable import MachoCore
@testable import MachoView
@testable import RealmHelper

final class DiaryDetailViewTest: XCTestCase {
    
    /// 画面表示時の変更監視処理の確認
    ///
    /// # 確認する仕様
    /// - 画面表示時に日記の変更監視を開始すること
    /// - 表示している日記の内容が更新されたら画面の内容が更新されること
    /// - ナビゲーションの戻るボタンを押下したら監視を終了して画面が閉じること
    @MainActor
    func testOnAppearView() async throws {
        
        // dismiss確認用のオブジェクト生成
        let isDismissInvoked = LockIsolated(false)
        // 日記監視を制御するPublisher生成
        let mockRealm = try await RealmTestHelper.getMockRealm()
        let mockClient = await DiaryEntityClient.getMockClient(realm: mockRealm, initialValue: [])
        
        let testStore = TestStore(
            initialState: .init(diary: Self.sampleDiaryEntity1),
            reducer: { DiaryDetailFeature() },
            withDependencies: {
                $0.diaryEntityClient = mockClient
                $0.dismiss = .init { isDismissInvoked.setValue(true) }
            }
        )
        
        await testStore.send(.onAppear)
        await testStore.receive(\.observePublisher)
        
        // 監視対象と対象外の日記更新
        let addResult = await mockClient.add(.init(Self.updatedSampleDiaryEntity1))
        XCTAssertTrue(addResult)
        
        await testStore.receive(\.didReceivedDiary) {
            
            $0.updateDiary(Self.updatedSampleDiaryEntity1)
        }
        
        await testStore.send(.tappedBackNavigationButton)
        
        // dismissしているか確認
        XCTAssertTrue(isDismissInvoked.value)
    }
    
    /// 編集ボタンタップ時の確認
    ///
    /// # 確認する仕様
    /// - 編集ボタンを押下したら編集画面にナビゲーション遷移すること
    @MainActor
    func testOnTappedEdit() async throws {
        
        let mockRealm = try await RealmTestHelper.getMockRealm()
        let mockClient = await DiaryEntityClient.getMockClient(realm: mockRealm, initialValue: [])
        let testStore = TestStore(
            initialState: DiaryDetailFeature.State(diary: Self.sampleDiaryEntity1),
            reducer: { DiaryDetailFeature() },
            withDependencies: {
                
                $0.diaryEntityClient = mockClient
            }
        )
        
        await testStore.send(.onAppear)
        await testStore.receive(\.observePublisher)
        
        await testStore.send(.tappedEditButton) {
            
            $0.navigationDestination = .editDiary(.init(editTarget: Self.sampleDiaryEntity1))
        }
    }
    
    /// 日記監視挙動の確認
    ///
    /// # 確認する仕様
    /// - 画面に表示していない日記の変更があっても画面の内容は変更されないこと
    /// - 画面が非表示になると日記の監視が終了すること
    @MainActor
    func testOnTappedShowMoreMessage() async throws {
        
        // dismiss確認用のオブジェクト生成
        let isDismissInvoked = LockIsolated(false)
        
        let mockRealm = try await RealmTestHelper.getMockRealm()
        let mockClient = await DiaryEntityClient.getMockClient(realm: mockRealm, initialValue: [])
        
        let testStore = TestStore(
            initialState: DiaryDetailFeature.State(diary: Self.sampleDiaryEntity1),
            reducer: { DiaryDetailFeature() },
            withDependencies: {
                
                $0.diaryEntityClient = mockClient
                $0.dismiss = .init { isDismissInvoked.setValue(true) }
            }
        )
        
        await testStore.send(.onAppear)
        await testStore.receive(\.observePublisher)
        
        // 監視対象と異なる日記が更新する
        let addResult = await mockClient.add(.init(Self.sampleDiaryEntity2))
        XCTAssertTrue(addResult)
        
        // dismissしていないか確認
        XCTAssertFalse(isDismissInvoked.value)
        
        await testStore.send(.tappedBackNavigationButton)
    }
}

// MARK: - Test Entity Definition

private extension DiaryDetailViewTest {
    
    static let sampleDiaryGoal1 = Goal.create(trainingType: .abs, isAchieved: true)
    static let sampleDiaryGoal2 = Goal.create(trainingType: .benchPress, isAchieved: false)
    
    static let sampleDiaryEntity1Id = UUID()
    static let sampleDiaryEntity2Id = UUID()
    
    static let sampleDiaryEntity1 = Diary.create(
        id: sampleDiaryEntity1Id,
        title: "sample1",
        mainText: "sample1 message",
        tags: [.fine]
    )
    static let updatedSampleDiaryEntity1 = Diary.create(
        id: sampleDiaryEntity1Id,
        title: "updated_sample1",
        mainText: "updated_sample1 message",
        tags: [.fine]
    )
    static let sampleDiaryEntity2 = Diary.create(
        id: sampleDiaryEntity2Id,
        title: "sample2",
        mainText: "sample2 message",
        tags: [.unfine]
    )
}
