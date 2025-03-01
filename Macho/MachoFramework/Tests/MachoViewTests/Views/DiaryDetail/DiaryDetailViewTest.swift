//
//  DiaryDetailViewTest.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/10/19.
//

import ComposableArchitecture
import XCTest

@testable import MachoView
@testable import MachoCore
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
        let mockClient = DiaryEntityClient.getMockClient(realm: mockRealm)
        
        let testStore = TestStore(initialState: DiaryDetailFeature.State(diary: Self.sampleDiaryEntity1),
                                  reducer: { DiaryDetailFeature() },
                                  withDependencies: {
            $0.diaryEntityClient = mockClient
            $0.dismiss = .init { isDismissInvoked.setValue(true) }
        })
        
        await testStore.send(.onAppear)
        await testStore.receive(\.observePublisher)
        
        // 監視対象と対象外の日記更新
        let addResult = await mockClient.add(Self.updatedSampleDiaryEntity1)
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
        let mockClient = DiaryEntityClient.getMockClient(realm: mockRealm)
        let testStore = TestStore(initialState: DiaryDetailFeature.State(diary: Self.sampleDiaryEntity1),
                                  reducer: { DiaryDetailFeature() },
                                  withDependencies: {
            
            $0.diaryEntityClient = mockClient
        })
        
        await testStore.send(.onAppear)
        await testStore.receive(\.observePublisher)
        
        await testStore.send(.tappedEditButton) {
            
            // TODO: 編集画面が実装されたら正しい値を入れる
            $0.path.append(.editDiaryView(.init(contact: .init(id: .init(.zero), name: "sample"))))
        }
        await testStore.send(.onDisappear)
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
        let mockClient = DiaryEntityClient.getMockClient(realm: mockRealm)
        
        let testStore = TestStore(initialState: DiaryDetailFeature.State(diary: Self.sampleDiaryEntity1),
                                  reducer: { DiaryDetailFeature() },
                                  withDependencies: {
            
            $0.diaryEntityClient = mockClient
            $0.dismiss = .init { isDismissInvoked.setValue(true) }
        })
        
        await testStore.send(.onAppear)
        await testStore.receive(\.observePublisher)
        
        // 監視対象と異なる日記が更新する
        let addResult = await mockClient.add(Self.sampleDiaryEntity2)
        XCTAssertTrue(addResult)
                
        await testStore.send(.onDisappear)
        
        // dismissしていないか確認
        XCTAssertFalse(isDismissInvoked.value)
    }
}

// MARK: - Test Entity Definition

private extension DiaryDetailViewTest {
    
    static let sampleDiaryGoal1 = ConcreteTrainingContentData(id: UUID(),
                                                              trainingType: ConcreteTrainingTypeData(id: UUID(), name: "腹筋"),
                                                              goalNumberOfSets: 3,
                                                              goalSetCount: 3,
                                                              actualNumberOfSets: 3,
                                                              actualSetCount: 3,
                                                              isAchieved: true)
    static let sampleDiaryGoal2 = ConcreteTrainingContentData(id: UUID(),
                                                              trainingType: ConcreteTrainingTypeData(id: UUID(), name: "ベンチプレス"),
                                                              goalNumberOfSets: 2,
                                                              goalSetCount: 1,
                                                              actualNumberOfSets: 1,
                                                              actualSetCount: 1,
                                                              isAchieved: false)
    
    static let sampleDiaryTag1 = ConcreteTrainingTagData(id: UUID(), tagName: "tag1")
    static let sampleDiaryTag2 = ConcreteTrainingTagData(id: UUID(), tagName: "tag2")
    
    static let sampleDiaryEntity1Id = UUID()
    static let sampleDiaryEntity2Id = UUID()
    
    static let sampleDiaryEntity1 = ConcreteDiaryData(id: sampleDiaryEntity1Id,
                                                      date: Date(),
                                                      title: "sample1",
                                                      mainText: "sample1 message",
                                                      goals: [sampleDiaryGoal1],
                                                      tags: [sampleDiaryTag1],
                                                      startTime: Date(),
                                                      endTime: nil)
    static let updatedSampleDiaryEntity1 = ConcreteDiaryData(id: sampleDiaryEntity1Id,
                                                             date: Date(),
                                                             title: "updated_sample1",
                                                             mainText: "updated_sample1 message",
                                                             goals: [sampleDiaryGoal1],
                                                             tags: [sampleDiaryTag1],
                                                             startTime: Date(),
                                                             endTime: nil)
    static let sampleDiaryEntity2 = ConcreteDiaryData(id: sampleDiaryEntity2Id,
                                                      date: Date(),
                                                      title: "sample2",
                                                      mainText: "sample2 message",
                                                      goals: [sampleDiaryGoal2],
                                                      tags: [sampleDiaryTag2],
                                                      startTime: Date(),
                                                      endTime: nil)
}
