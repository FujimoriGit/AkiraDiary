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
                [DiaryData.createData(id: Self.diaryIdList[1], isAchieved: false, type: [.abs])]
            ),
            (
                [DiaryListFilterItem.achieved],
                [
                    DiaryData.createData(id: Self.diaryIdList[0]),
                    .createData(id: Self.diaryIdList[2], tag: [.fine]),
                    .createData(id: Self.diaryIdList[3],
                                isAchieved: true,
                                type: [.benchPress],
                                tag: [.unfine])
                ]
            ),
            (
                [DiaryListFilterItem.create(.fine)],
                [DiaryData.createData(id: Self.diaryIdList[2], tag: [.fine])]
            ),
            (
                [DiaryListFilterItem.create(.unfine)],
                [DiaryData.createData(id: Self.diaryIdList[3],
                                      isAchieved: true,
                                      type: [.benchPress],
                                      tag: [.unfine])]
            ),
            (
                [DiaryListFilterItem.create(.abs)],
                [DiaryData.createData(id: Self.diaryIdList[1],
                                      isAchieved: false,
                                      type: [.abs])]
            ),
            (
                [DiaryListFilterItem.create(.benchPress)],
                [DiaryData.createData(id: Self.diaryIdList[3],
                                      isAchieved: true,
                                      type: [.benchPress],
                                      tag: [.unfine])]
            ),
            (
                [DiaryListFilterItem.achieved, .create(.fine), .create(.benchPress)],
                [
                    DiaryData.createData(id: Self.diaryIdList[0]),
                    .createData(id: Self.diaryIdList[2], tag: [.fine]),
                    .createData(id: Self.diaryIdList[3],
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
                    DiaryData.createData(id: Self.diaryIdList[0]),
                    .createData(id: Self.diaryIdList[1], isAchieved: false, type: [.abs]),
                    .createData(id: Self.diaryIdList[2], tag: [.fine]),
                    .createData(id: Self.diaryIdList[3],
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
            .createData(id: Self.diaryIdList[0]),
            .createData(id: Self.diaryIdList[1], isAchieved: false, type: [.abs]),
            .createData(id: Self.diaryIdList[2], tag: [.fine]),
            .createData(id: Self.diaryIdList[3],
                        isAchieved: true,
                        type: [.benchPress],
                        tag: [.unfine]),
        ]
        
        let sut = DiaryList(elements: inputDiaries.map { .init($0) })
        
        let result = sut.getFilteredList(filters: inputFilter)
        
        #expect(result == expected.map { .init($0) })
    }
    
    @Test(
        arguments: [
            (
                DiaryList(elements: []),
                [
                    DiaryData.create(id: diaryIdList[2], date: .create(year: 2024, month: 2, day: 2)),
                    .create(id: diaryIdList[1], date: .create(year: 2025, month: 2, day: 2))
                ],
                [
                    DiaryData.create(id: diaryIdList[1], date: .create(year: 2025, month: 2, day: 2)),
                    .create(id: diaryIdList[2], date: .create(year: 2024, month: 2, day: 2))
                ]
            ),
            (
                DiaryList(elements: []),
                [DiaryData.createData(id: diaryIdList[0], date: .create(year: 2025, month: 2, day: 1), tag: [.fine])],
                [DiaryData.createData(id: diaryIdList[0], date: .create(year: 2025, month: 2, day: 1), tag: [.fine])]
            ),
            (
                DiaryList(elements: [
                    .init(.create(id: diaryIdList[1], date: .create(year: 2025, month: 2, day: 10)))
                ]),
                [DiaryData.create(id: diaryIdList[0], date: .create(year: 2025, month: 2, day: 1))],
                [
                    DiaryData.create(id: diaryIdList[1], date: .create(year: 2025, month: 2, day: 10)),
                    .create(id: diaryIdList[0], date: .create(year: 2025, month: 2, day: 1))
                ]
            )
        ]
    )
    func 追加の日記リストは既存の日記リストにマージし日記作成日の降順にする(
        initialList: DiaryList,
        addingDiaries: [DiaryData],
        expected: [DiaryData]
    ) throws {
        
        let currentDiaryItems: [DiaryListItem] = [
            .create(id: Self.diaryIdList[0], date: .create(year: 2025, month: 2, day: 1)),
        ]
            .map { .init($0) }
        
        var sut = initialList
        sut.addLoadedDiaries(addingDiaries)
        
        let expected = DiaryList(elements: expected.map { .init($0) })
        #expect(sut == expected)
    }
    
    @Test
    func 日記削除は既存の日記リストから指定の日記のみを削除する() throws {
        
        let currentDiaryItems: [DiaryListItem] = [
            .create(id: Self.diaryIdList[0], date: .create(year: 2025, month: 2, day: 1)),
        ]
            .map { .init($0) }
        var sut = DiaryList(elements: currentDiaryItems)
        
        sut.deleteDiaryById(Self.diaryIdList[0])
        
        #expect(sut.elements == [])
    }
    
    @Test
    func IDで指定した日記を取得する() async throws {
        
        let inputDiaries: [DiaryData] = [
            .createData(id: Self.diaryIdList[0]),
            .createData(id: Self.diaryIdList[1], tag: [.fine]),
            .createData(id: Self.diaryIdList[2],
                        isAchieved: true,
                        type: [.benchPress],
                        tag: [.unfine])
        ]
        var sut = DiaryList(elements: inputDiaries.map { .init($0) })
        
        let result = try #require(sut.getTargetDiaryById(Self.diaryIdList[0]))
        
        #expect(result == .init(inputDiaries[0]))
    }
    
    @Test
    func 次の日記を取得するための日記リストの一番古い日付を返す() async throws {
        
        let inputDiaries: [DiaryData] = [
            .createData(id: Self.diaryIdList[0], date: .create(year: 2025, month: 2, day: 2)),
            .createData(id: Self.diaryIdList[1], date: .create(year: 2024, month: 2, day: 2))
        ]
        var sut = DiaryList(elements: inputDiaries.map { .init($0) })
        
        let result = try #require(sut.getLoadStartDate())
        
        #expect(result == inputDiaries[1].date)
    }
}

fileprivate extension DiaryData {
    
    static let defaultEndDate: Date = .create(year: 2025, month: 1, day: 1)
    
    static func createData(id: UUID,
                           date: Date = .create(year: 2025, month: 2, day: 1),
                           isAchieved: Bool = true,
                           type trainingType: [TrainingTypeData] = [],
                           tag: [TrainingTagData] = [],
                           isFinished: Bool = true) -> Self {
        
        let goals: [TrainingContentData] = trainingType.map {
            .create(id: id,
                    trainingType: $0,
                    isAchieved: isAchieved)
        }
        return .create(id: id,
                       date: date,
                       goals: goals,
                       tags: tag,
                       endTime: isFinished ? Self.defaultEndDate : nil)
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
