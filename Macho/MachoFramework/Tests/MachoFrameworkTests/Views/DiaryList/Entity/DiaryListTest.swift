//
//  MachoFramework
//
//  DiaryListTest.swift
//
//  Created by stotic-dev on 2025/02/02
//  Copyright © Macho All rights reserved.
//

import Foundation
import Testing
@testable import MachoView

struct DiaryListTest {
    
    static let diaryIdList = (1...4).map { _ in UUID() }
    
    typealias DiaryListItem = DiaryListItemFeature.State

    @Test(
        "日記リストのフィルタリング処理は、フィルターにマッチする項目が一つでもある日記のリストを返す",
        arguments: [
            (
                [DiaryListFilterItem.notAchieved],
                [DiaryData.create(id: Self.diaryIdList[1],
                                  isAchieved: false,
                                  type: [.abs])]
            ),
            (
                [DiaryListFilterItem.achieved],
                [
                    DiaryData.create(id: Self.diaryIdList[0]),
                    .create(id: Self.diaryIdList[2], tag: [.fine]),
                    .create(id: Self.diaryIdList[3],
                            isAchieved: true,
                            type: [.benchPress],
                            tag: [.unfine])
                ]
            ),
            (
                [DiaryListFilterItem.create(.fine)],
                [DiaryData.create(id: Self.diaryIdList[2], tag: [.fine])]
            ),
            (
                [DiaryListFilterItem.create(.unfine)],
                [DiaryData.create(id: Self.diaryIdList[3],
                                  isAchieved: true,
                                  type: [.benchPress],
                                  tag: [.unfine])]
            ),
            (
                [DiaryListFilterItem.create(.abs)],
                [DiaryData.create(id: Self.diaryIdList[1],
                                  isAchieved: false,
                                  type: [.abs])]
            ),
            (
                [DiaryListFilterItem.create(.benchPress)],
                [DiaryData.create(id: Self.diaryIdList[3],
                                  isAchieved: true,
                                  type: [.benchPress],
                                  tag: [.unfine])]
            ),
            (
                [DiaryListFilterItem.achieved, .create(.fine), .create(.benchPress)],
                [
                    DiaryData.create(id: Self.diaryIdList[0]),
                    .create(id: Self.diaryIdList[2], tag: [.fine]),
                    .create(id: Self.diaryIdList[3],
                            isAchieved: true,
                            type: [.benchPress],
                            tag: [.unfine])
                ]
            ),
            (
                [
                    DiaryListFilterItem.achieved,
                    .create(.unfine),
                    .create(.benchPress),
                    .create(.abs)
                ],
                [
                    DiaryData.create(id: Self.diaryIdList[0]),
                    .create(id: Self.diaryIdList[1], isAchieved: false, type: [.abs]),
                    .create(id: Self.diaryIdList[2], tag: [.fine]),
                    .create(id: Self.diaryIdList[3],
                            isAchieved: true,
                            type: [.benchPress],
                            tag: [.unfine])
                ]
            ),
            ([DiaryListFilterItem.create(.init(id: UUID(), tagName: "Test"))], [])
        ]
    )
    func フィルタリング処理の確認(
        inputFilter: [DiaryListFilterItem],
        expected: [DiaryData]
    ) throws {
        
        let inputDiaries: [DiaryData] = [
            .create(id: Self.diaryIdList[0]),
            .create(id: Self.diaryIdList[1], isAchieved: false, type: [.abs]),
            .create(id: Self.diaryIdList[2], tag: [.fine]),
            .create(id: Self.diaryIdList[3],
                    isAchieved: true,
                    type: [.benchPress],
                    tag: [.unfine])
        ]
        
        let sut = DiaryList(elements: inputDiaries.map { .init($0) })
        
        let result = sut.getFilteredList(filters: inputFilter)
        
        let expectedResult = DiaryList(elements: expected.map { .init($0) })
        #expect(result == expectedResult)
        #expect(result.hasElements == !expected.isEmpty)
    }
    
    @Test(
        arguments: [
            (
                [
                    DiaryData.create(id: diaryIdList[1], date: .create(year: 2025, month: 2, day: 2)),
                    DiaryData.create(id: diaryIdList[2], date: .create(year: 2024, month: 2, day: 2))
                ],
                [
                    DiaryData.create(id: diaryIdList[1], date: .create(year: 2025, month: 2, day: 2)),
                    DiaryData.create(id: diaryIdList[0], date: .create(year: 2025, month: 2, day: 1)),
                    DiaryData.create(id: diaryIdList[2], date: .create(year: 2024, month: 2, day: 2))
                ]
            ),
            (
                [DiaryData.create(id: diaryIdList[0], date: .create(year: 2025, month: 2, day: 1), tag: [.fine])],
                [DiaryData.create(id: diaryIdList[0], date: .create(year: 2025, month: 2, day: 1), tag: [.fine])]
            )
        ]
    )
    func 追加の日記リストは既存の日記リストにマージし日記作成日の降順にする(
        addingDiaries: [DiaryData],
        expected: [DiaryData]
    ) throws {
        
        let currentDiaryItems: [DiaryListItem] = [
            .create(id: Self.diaryIdList[0], date: .create(year: 2025, month: 2, day: 1)),
        ]
            .map { .init($0) }
        let sut = DiaryList(adding: addingDiaries, current: currentDiaryItems)
        
        let result = sut.elements
        
        let expectedResult: [DiaryListItem] = expected.map { .init($0) }
        #expect(result == expectedResult)
        #expect(sut.hasElements == !expected.isEmpty)
    }
    
    @Test
    func 日記削除は既存の日記リストから指定の日記のみを削除する() throws {
        
        let currentDiaryItems: [DiaryListItem] = [
            .create(id: Self.diaryIdList[0], date: .create(year: 2025, month: 2, day: 1)),
        ]
            .map { .init($0) }
        let sut = DiaryList(removing: Self.diaryIdList[0], current: currentDiaryItems)
        
        let result = sut.elements
        
        #expect(result == [])
    }
}

fileprivate extension DiaryData {
    
    static func create(id: UUID,
                       date: Date = .create(year: 2025, month: 2, day: 1),
                       isAchieved: Bool = true,
                       type trainingType: [TrainingTypeData] = [],
                       tag: [TrainingTagData] = []) -> Self {
        
        let goals: [TrainingContentData] = trainingType.map {
            .create(id: id,
                    trainingType: $0,
                    isAchieved: isAchieved)
        }
        return .create(id: id, date: date, goals: goals, tags: tag)
    }
}

fileprivate extension DiaryListFilterItem {
    
    static let achieved: Self = .init(target: .achievement,
                                      filterItemId: UUID(DiaryListFilterTarget.achievement.num),
                                      value: "達成している")
    static let notAchieved: Self = .init(target: .achievement,
                                         filterItemId: UUID(DiaryListFilterTarget.achievement.num),
                                         value: "達成していない")
    
    static func create(_ tag: TrainingTagData) -> Self {
        
        return .init(target: .tag,
                     filterItemId: tag.id,
                     value: tag.tagName)
    }
    
    static func create(_ trainingType: TrainingTypeData) -> Self {
        
        return .init(target: .trainingType,
                     filterItemId: trainingType.id,
                     value: trainingType.name)
    }
}
