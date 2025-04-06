//
//  MachoFramework
//
//  ActivityResultsTest.swift
//
//  Created by stotic-dev on 2025/01/24
//  Copyright © Macho All rights reserved.
//

import Foundation
import Testing
@testable import MachoView

// MARK: - テストスイートの定義

@Suite("アクティビティグラフ集計の振る舞いに関するテスト")
struct ActivityResultsTest {
    
    @Suite("日ごとに目標達成したかどうかのカレンダーの装飾を返す振る舞いを検証する. 一日に複数の日記がある場合は、すべての目標達成していれば達成、それ以外は未達成とみなす")
    struct GetDecorationTest {}
}

// MARK: - `buildCalendarDecorator`のテスト

extension ActivityResultsTest.GetDecorationTest {
    
    static let diaryIds = [UUID(), UUID(), UUID(), UUID()]
    
    @Test(
        "指定されている期間内の日記データ以外は除外して、日ごとに目標達成したかどうかの装飾を返す",
        arguments: zip(
            [
                InputAsCreateActivityResults(
                    [DiaryData].createDiaries(
                        (Self.diaryIds[0], .create(year: 2025, month: 1, day: 1), true, .abs),
                        (Self.diaryIds[1], .create(year: 2025, month: 1, day: 7), false, .abs),
                        (Self.diaryIds[2], .create(year: 2025, month: 1, day: 8), true, .abs),
                        (Self.diaryIds[3], .create(year: 2024, month: 12, day: 31), true, .abs)
                    ),
                    period: .week
                ),
                InputAsCreateActivityResults(
                    [DiaryData].createDiaries(
                        (Self.diaryIds[0], .create(year: 2025, month: 1, day: 1), false, .abs),
                        (Self.diaryIds[1], .create(year: 2025, month: 1, day: 31), true, .abs),
                        (Self.diaryIds[2], .create(year: 2025, month: 2, day: 1), true, .abs)
                    ),
                    period: .month
                ),
                InputAsCreateActivityResults(
                    [DiaryData].createDiaries(
                        (Self.diaryIds[0], .create(year: 2025, month: 1, day: 1), false, .abs),
                        (Self.diaryIds[1], .create(year: 2025, month: 12, day: 31), true, .abs),
                        (Self.diaryIds[2], .create(year: 2026, month: 1, day: 1), true, .abs)
                    ),
                    period: .year
                ),
                InputAsCreateActivityResults(
                    [DiaryData].createDiaries(
                        (Self.diaryIds[0], .create(year: 2025, month: 1, day: 1), true, .abs),
                        (Self.diaryIds[1], .create(year: 2025, month: 1, day: 1), false, .abs),
                        (Self.diaryIds[2], .create(year: 2025, month: 1, day: 7), true, .abs),
                        (Self.diaryIds[3], .create(year: 2025, month: 1, day: 7), true, .abs)
                    ),
                    period: .week
                ),
            ],
            [
                [
                    ActivityResultOfDay.create(.createDiaries(
                        (Self.diaryIds[0], .create(year: 2025, month: 1, day: 1), true, .abs)
                    )),
                    ActivityResultOfDay.create(.createDiaries(
                        (Self.diaryIds[1], .create(year: 2025, month: 1, day: 7), false, .abs)
                    ))
                ],
                [
                    ActivityResultOfDay.create(.createDiaries(
                        (Self.diaryIds[0], .create(year: 2025, month: 1, day: 1), false, .abs)
                    )),
                    ActivityResultOfDay.create(.createDiaries(
                        (Self.diaryIds[1], .create(year: 2025, month: 1, day: 31), true, .abs)
                    ))
                ],
                [
                    ActivityResultOfDay.create(.createDiaries(
                        (Self.diaryIds[0], .create(year: 2025, month: 1, day: 1), false, .abs)
                    )),
                    ActivityResultOfDay.create(.createDiaries(
                        (Self.diaryIds[1], .create(year: 2025, month: 12, day: 31), true, .abs)
                    ))
                ],
                [
                    ActivityResultOfDay.create(.createDiaries(
                        (Self.diaryIds[0], .create(year: 2025, month: 1, day: 1), true, .abs),
                        (Self.diaryIds[1], .create(year: 2025, month: 1, day: 1), false, .abs)
                    )),
                    ActivityResultOfDay.create(.createDiaries(
                        (Self.diaryIds[2], .create(year: 2025, month: 1, day: 7), true, .abs),
                        (Self.diaryIds[3], .create(year: 2025, month: 1, day: 7), true, .abs)
                    ))
                ],
            ]
        )
    )
    func get_decoration_if_contain_input_period(
        input: InputAsCreateActivityResults,
        expected: [ActivityResultOfDay]
    ) throws {
        
        let sut = input.activityResults
        
        let result = sut.buildCalendarDecorator()
        
        #expect(result == createExpectedDecorationDic(expected))
    }
    
    @Test(
        "指定したトレーニング種目を含む日記データ以外は除外して、日ごとに目標達成したかどうかの装飾を返す. 指定したトレーニング種目がない場合は、トレーニング種目のフィルターは行わない.",
        arguments: zip(
            [
                InputAsCreateActivityResults(
                    [DiaryData].createDiaries(
                        (Self.diaryIds[0], .create(year: 2025, month: 1, day: 1), false, .benchPress),
                        (Self.diaryIds[1], .create(year: 2025, month: 1, day: 1), true, .abs),
                        (Self.diaryIds[2], .create(year: 2025, month: 1, day: 2), false, .abs),
                        (Self.diaryIds[3], .create(year: 2025, month: 1, day: 3), true, .abs)
                    ),
                    selectedTraining: [.abs]
                ),
                InputAsCreateActivityResults(
                    [DiaryData].createDiaries(
                        (Self.diaryIds[0], .create(year: 2025, month: 1, day: 1), false, .benchPress),
                        (Self.diaryIds[1], .create(year: 2025, month: 1, day: 1), true, .abs),
                        (Self.diaryIds[2], .create(year: 2025, month: 1, day: 2), false, .benchPress),
                        (Self.diaryIds[3], .create(year: 2025, month: 1, day: 3), true, .abs)
                    ),
                    selectedTraining: []
                )
            ],
            [
                [
                    ActivityResultOfDay.create(.createDiaries(
                        (Self.diaryIds[1], .create(year: 2025, month: 1, day: 1), true, .abs)
                    )),
                    ActivityResultOfDay.create(.createDiaries(
                        (Self.diaryIds[2], .create(year: 2025, month: 1, day: 2), false, .abs)
                    )),
                    ActivityResultOfDay.create(.createDiaries(
                        (Self.diaryIds[3], .create(year: 2025, month: 1, day: 3), true, .abs)
                    ))
                ],
                [
                    ActivityResultOfDay.create(.createDiaries(
                        (Self.diaryIds[0], .create(year: 2025, month: 1, day: 1), false, .benchPress),
                        (Self.diaryIds[1], .create(year: 2025, month: 1, day: 1), true, .abs)
                    )),
                    ActivityResultOfDay.create(.createDiaries(
                        (Self.diaryIds[2], .create(year: 2025, month: 1, day: 2), false, .benchPress)
                    )),
                    ActivityResultOfDay.create(.createDiaries(
                        (Self.diaryIds[3], .create(year: 2025, month: 1, day: 3), true, .abs)
                    ))
                ]
            ]
        )
    )
    func get_decoration_if_match_training_type(
        input: InputAsCreateActivityResults,
        expected: [ActivityResultOfDay]
    ) throws {
        
        let sut = input.activityResults
        
        let result = sut.buildCalendarDecorator()
        
        #expect(result == createExpectedDecorationDic(expected))
    }
}

extension ActivityResultsTest.GetDecorationTest {
    
    struct InputAsCreateActivityResults {
        
        let activityResults: ActivityResults
        
        init(_ diaries: [DiaryData],
             startDate: Date = .create(year: 2025, month: 1, day: 1),
             period: ActivityPeriod = .week,
             selectedTraining: [TrainingTypeData] = [.abs]) {
            
            activityResults = .init(diaries,
                                    periodFilter: .init(startPeriodDate: startDate,
                                                        period: period),
                                    trainingTypeFilter: .init(trainingTypeList: selectedTraining))
        }
    }
    
    func createExpectedDecorationDic(_ resultOfDayList: [ActivityResultOfDay]) -> [DateComponents: ActivityResultDecoration] {
        
        return resultOfDayList.reduce(into: [:]) {
            
            $0.updateValue(.init(isAchievedOfDay: $1.isAchieved),
                           forKey: $1.targetDate)
        }
    }
}

// MARK: - ActivityResultsTest特有のテストヘルパーメソッド定義

fileprivate extension ActivityResultOfDay {
    
    static func create(_ diaries: [DiaryData]) -> ActivityResultOfDay {
        
        let calendar = Calendar.current
        let targetData = calendar.dateComponents([.year, .month, .day],
                                                 from: diaries[0].date)
        return ActivityResultOfDay(targetDate: targetData,
                                   activities: diaries.map {
            
            return .init(id: $0.id, title: $0.title, isAchieved: $0.isAchieved)
        })
    }
}

fileprivate extension Array where Element == DiaryData {
    
    static func createDiaries(_ params: (id: UUID, date: Date, isAchieved: Bool, trainingType: TrainingTypeData)...) -> [DiaryData] {
        
        return params.map {
            
            return .create(id: $0.id,
                           date: $0.date,
                           goals: [.create(trainingType: $0.trainingType,
                                           isAchieved: $0.isAchieved)])
        }
    }
}
