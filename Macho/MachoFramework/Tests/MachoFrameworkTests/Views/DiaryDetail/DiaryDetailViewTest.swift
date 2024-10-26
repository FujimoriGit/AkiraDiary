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
    func testOnAppearView() async throws {
        
        let testStore = TestStore(initialState: DiaryDetailFeature.State(diary: Self.sampleDiaryEntity1),
                                  reducer: { DiaryDetailFeature() },
                                  withDependencies: {
            $0.diaryListFetchApi = .testValue
        })
        
        await testStore.send(.onAppear)
        // TODO: 監視対象と対象外の日記更新を送信する
        await testStore.receive(\.didReceivedDiary) {
            
            $0.diary = Self.updatedSampleDiaryEntity1
        }
        await testStore.send(.onDisappear)
    }
    
    /// 編集ボタンタップ時の確認
    func testOnTappedEdit() async throws {
        
        let testStore = TestStore(initialState: DiaryDetailFeature.State(diary: Self.sampleDiaryEntity1),
                                  reducer: { DiaryDetailFeature() },
                                  withDependencies: {
            $0.diaryListFetchApi = .testValue
        })
        
        await testStore.send(.onAppear)
        await testStore.send(.tappedEditButton) {
            $0.path = .init()
        }
        await testStore.send(.onDisappear)
    }
    
    /// さらに表示ボタンタップ時の確認
    func testOnTappedShowMoreMessage() async throws {
        
        let testStore = TestStore(initialState: DiaryDetailFeature.State(diary: Self.sampleDiaryEntity1),
                                  reducer: { DiaryDetailFeature() },
                                  withDependencies: {
            $0.diaryListFetchApi = .testValue
        })
        
        await testStore.send(.onAppear)
        await testStore.send(.tappedShowMoreMessageButton) {
            
            $0.isShownMoreMessage = true
        }
        await testStore.send(.tappedShowMoreMessageButton) {
            
            $0.isShownMoreMessage = false
        }
        await testStore.send(.onDisappear)
    }
}

// MARK: - Test Entity Definition

private extension DiaryDetailViewTest {
    
    static let sampleDiaryGoal1 = TrainingGoalEntity(id: UUID(),
                                                     goalType: TrainingTypeEntity(id: UUID(), name: "腹筋"),
                                                     numberOfSets: 3,
                                                     setCount: 3,
                                                     startTime: Date(),
                                                     endTime: Date(),
                                                     isSuccess: true)
    static let sampleDiaryGoal2 = TrainingGoalEntity(id: UUID(),
                                                     goalType: TrainingTypeEntity(id: UUID(), name: "ベンチプレス"),
                                                     numberOfSets: 2,
                                                     setCount: 1,
                                                     startTime: Date(),
                                                     endTime: Date(),
                                                     isSuccess: false)
    
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
