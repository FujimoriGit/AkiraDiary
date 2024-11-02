//
//  DiaryDetailViewTest.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/10/19.
//

import Combine
import ComposableArchitecture
import RealmHelper
import XCTest

@testable import MachoView

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
        let diaryPublisher = PassthroughSubject<[DiaryData], Never>()
        
        let testStore = TestStore(initialState: DiaryDetailFeature.State(diary: Self.sampleDiaryEntity1),
                                  reducer: { DiaryDetailFeature() },
                                  withDependencies: {
            $0.diaryListFetchApi = createMockDiaryClient(diaryPublisher.eraseToAnyPublisher())
            $0.dismiss = .init { isDismissInvoked.setValue(true) }
        })
        
        await testStore.send(.onAppear)
        
        // 監視対象と対象外の日記更新
        diaryPublisher.send([Self.updatedSampleDiaryEntity1, Self.sampleDiaryEntity2])
        
        await testStore.receive(\.didReceivedDiary) {
            
            $0.diary = Self.updatedSampleDiaryEntity1
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
        
        let testStore = TestStore(initialState: DiaryDetailFeature.State(diary: Self.sampleDiaryEntity1),
                                  reducer: { DiaryDetailFeature() },
                                  withDependencies: {
            $0.diaryListFetchApi = createMockDiaryClient(PassthroughSubject<[DiaryData], Never>().eraseToAnyPublisher())
        })
        
        await testStore.send(.onAppear)
        await testStore.send(.tappedEditButton) {
            
            // TODO: 編集画面が実装されたら正しい値を入れる
            $0.path.append(.editDiaryView(.init(contact: .init(id: .init(.zero), name: "sample"))))
        }
        await testStore.send(.onDisappear)
    }
    
    /// さらに表示ボタンタップ時の確認
    ///
    /// # 確認する仕様
    /// - 画面に表示していない日記の変更があっても画面の内容は変更されないこと
    /// - さらに表示するボタンを押下すると本文のテキストが全文表示されること
    /// - 本文を省略するボタンを押下すると本文のテキストが省略されること
    /// - 画面が非表示になると日記の監視が終了すること
    @MainActor
    func testOnTappedShowMoreMessage() async throws {
        
        // 日記監視を制御するPublisher生成
        let diaryPublisher = PassthroughSubject<[DiaryData], Never>()
        // dismiss確認用のオブジェクト生成
        let isDismissInvoked = LockIsolated(false)
        
        let testStore = TestStore(initialState: DiaryDetailFeature.State(diary: Self.sampleDiaryEntity1),
                                  reducer: { DiaryDetailFeature() },
                                  withDependencies: {
            $0.diaryListFetchApi = createMockDiaryClient(diaryPublisher.eraseToAnyPublisher())
            $0.dismiss = .init { isDismissInvoked.setValue(true) }
        })
        
        await testStore.send(.onAppear)
        
        // 監視対象と異なる日記が更新する
        diaryPublisher.send([Self.sampleDiaryEntity1, Self.sampleDiaryEntity2])
        
        await testStore.receive(\.didReceivedDiary)
        
        await testStore.send(.tappedShowMoreMessageButton) {
            
            $0.isShownMoreMessage = true
        }
        await testStore.send(.tappedShowMoreMessageButton) {
            
            $0.isShownMoreMessage = false
        }
        await testStore.send(.onDisappear)
        
        // dismissしていないか確認
        XCTAssertFalse(isDismissInvoked.value)
    }
}

// MARK: - Test utility method {

private extension DiaryDetailViewTest {
    
    func createMockDiaryClient(_ diaryPublisher: AnyPublisher<[DiaryData], Never>) -> DiaryClient {
        
        let mockRealm = RealmAccessorMock(expectedNotification: diaryPublisher)
        return .createCustomValue(mockRealm)
    }
}

// MARK: - Test Entity Definition

private extension DiaryDetailViewTest {
    
    static let sampleDiaryGoal1 = TrainingContentData(id: UUID(),
                                                      trainingType: TrainingTypeEntity(id: UUID(), name: "腹筋"),
                                                      goalNumberOfSets: 3,
                                                      goalSetCount: 3,
                                                      actualNumberOfSets: 3,
                                                      actualSetCount: 3,
                                                      startTime: Date(),
                                                      endTime: Date())
    static let sampleDiaryGoal2 = TrainingContentData(id: UUID(),
                                                      trainingType: TrainingTypeEntity(id: UUID(), name: "ベンチプレス"),
                                                      goalNumberOfSets: 2,
                                                      goalSetCount: 1,
                                                      actualNumberOfSets: 1,
                                                      actualSetCount: 1,
                                                      startTime: Date(),
                                                      endTime: Date())
    
    static let sampleDiaryTag1 = TrainingTagEntity(id: UUID(), tagName: "tag1")
    static let sampleDiaryTag2 = TrainingTagEntity(id: UUID(), tagName: "tag2")
    
    static let sampleDiaryEntity1Id = UUID()
    static let sampleDiaryEntity2Id = UUID()
    
    static let sampleDiaryEntity1 = DiaryEntity(id: sampleDiaryEntity1Id,
                                                date: Date(),
                                                title: "sample1",
                                                mainText: "sample1 message",
                                                goals: [sampleDiaryGoal1],
                                                tags: [sampleDiaryTag1])
    static let updatedSampleDiaryEntity1 = DiaryEntity(id: sampleDiaryEntity1Id,
                                                       date: Date(),
                                                       title: "updated_sample1",
                                                       mainText: "updated_sample1 message",
                                                       goals: [sampleDiaryGoal1],
                                                       tags: [sampleDiaryTag1])
    static let sampleDiaryEntity2 = DiaryEntity(id: sampleDiaryEntity2Id,
                                                date: Date(),
                                                title: "sample2",
                                                mainText: "sample2 message",
                                                goals: [sampleDiaryGoal2],
                                                tags: [sampleDiaryTag2])
}
