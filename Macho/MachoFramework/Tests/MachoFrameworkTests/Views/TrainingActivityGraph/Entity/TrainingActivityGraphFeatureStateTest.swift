//
//  MachoFramework
//
//  TrainingActivityGraphFeatureStateTest.swift
//
//  Created by stotic-dev on 2025/01/23
//  Copyright © Macho All rights reserved.
//

import Foundation
import Testing
@testable import MachoView

@Suite("グラフ画面の状態更新ロジックの確認")
struct TrainingActivityGraphFeatureStateTest {
    
    // MARK: - 正常系

    @Test(
        "グラフの表示期間を更新したら、カレンダーの表示期間も表示開始期間から表示期間までの期間に更新される",
        arguments: ActivityPeriod.allCases, [Date.distantPast, .now, .distantFuture]
    )
    func update_calendar_display_period_when_update_period(input: ActivityPeriod,
                                                           startPeriodDate: Date) throws {
        
        var state = TrainingActivityGraphFeature.State(activityStartPeriod: startPeriodDate)
        
        state.updatePeriod(input)
        
        var expectedState = TrainingActivityGraphFeature.State(activityStartPeriod: startPeriodDate)
        expectedState.activityPeriod = input
        expectedState.calendar.displayInterval = .create(
            from: expectedState.activityStartPeriod,
            period: input
        )
        #expect(state == expectedState)
    }
    
    @Test(
        "グラフの表示開始期間を更新したら、カレンダーの表示期間も表示開始期間から表示期間までの期間に更新される",
        arguments: [Date.distantPast, .now, .distantFuture], ActivityPeriod.allCases
    )
    func update_calendar_display_period_when_update_start_period_date(
        input: Date,
        period: ActivityPeriod
    ) throws {
        
        var state = TrainingActivityGraphFeature.State()
        
        state.updateStartPeriodDate(input)
        
        var expectedState = TrainingActivityGraphFeature.State()
        expectedState.activityStartPeriod = input
        expectedState.calendar.displayInterval = .create(
            from: input,
            period: expectedState.activityPeriod
        )
        #expect(state == expectedState)
    }
    
    @Test(
        "グラフ表示期間のフィルター値を更新すると、カレンダーの表示期間も表示開始期間から表示期間までの期間に更新される",
        arguments: zip(
            [
                InputAsActivityPeriodFilter(period: 0, startPeriodTimeInterval: Date.distantPast.timeIntervalSince1970),
                InputAsActivityPeriodFilter(period: 1, startPeriodTimeInterval: 0),
                InputAsActivityPeriodFilter(period: 2, startPeriodTimeInterval: Date.distantFuture.timeIntervalSince1970)
            ],
            [
                ExpectedAsActivityPeriodFilter(period: .week,
                                               startPeriodDate: .distantPast),
                ExpectedAsActivityPeriodFilter(period: .month,
                                               startPeriodDate: Date(timeIntervalSince1970: 0)),
                ExpectedAsActivityPeriodFilter(period: .year,
                                               startPeriodDate: .distantFuture)
            ]
        )
    )
    func update_calendar_display_period_when_update_period_filter(
        input: InputAsActivityPeriodFilter,
        expected: ExpectedAsActivityPeriodFilter
    ) throws {
        
        let periodFilter = try #require(
            ActivityPeriodFilter(timestamp: input.startPeriodTimeInterval,
                                 period: input.period)
        )
        var state = TrainingActivityGraphFeature.State()
        
        state.updatePeriodFilter(periodFilter)
        
        var expectedState = TrainingActivityGraphFeature.State()
        expectedState.activityStartPeriod = expected.startPeriodDate
        expectedState.activityPeriod = expected.period
        expectedState.calendar.displayInterval = .create(
            from: expected.startPeriodDate,
            period: expected.period
        )
        #expect(state == expectedState)
    }
    
    @Test("日記データで更新する時、アクティビティの結果とカレンダーのデコレーション内容を更新する")
    func update_calendar_decoration_when_update_activity_result() {
        
        // 各依存の準備
        
        let diaryId_1 = UUID()
        
        let inputDiaries = createDiaries(
            (diaryId_1, .create(year: 2025, month: 1, day: 1), true)
        )
        let initialCalendar = ActivityCalendarFeature.State(displayInterval: .init(start: .now, duration: .zero), decorationDic: [:])
        var state = TrainingActivityGraphFeature.State(activityStartPeriod: .create(year: 2025, month: 1, day: 1),
                                                       activityPeriod: .month,
                                                       calendar: initialCalendar)
        
        // 対象メソッドの実行
        
        state.updateActivityResults(inputDiaries)
        
        // 検証
        
        var expectedState = TrainingActivityGraphFeature.State(
            activityStartPeriod: .create(year: 2025, month: 1, day: 1),
            activityPeriod: .month,
            calendar: initialCalendar
        )
        expectedState.activityResultList = ActivityResults(
            createDiaries(
                (diaryId_1, .create(year: 2025, month: 1, day: 1), true)
            ),
            periodFilter: .init(startPeriodDate: .create(year: 2025, month: 1, day: 1),
                                period: .month),
            trainingTypeFilter: .init(selectedIdList: [])
        )
        expectedState.calendar.decorationDic = [
            .createDay(year: 2025, month: 1, day: 1): ActivityResultDecoration(activityResult: .init(dayOfdiaries: createDiaries((diaryId_1, .create(year: 2025, month: 1, day: 1), true))))
         ]
        #expect(state == expectedState)
    }
}

extension TrainingActivityGraphFeatureStateTest {
    
    struct InputAsActivityPeriodFilter {
        
        let period: Int
        let startPeriodTimeInterval: TimeInterval
    }
    
    struct ExpectedAsActivityPeriodFilter {
        
        let period: ActivityPeriod
        let startPeriodDate: Date
    }
    
    struct ExpectedAsActivityResult {
        
        let activityResults: ActivityResults
        let decorationDic: [DateComponents: ActivityResultDecoration]
    }
}

private extension TrainingActivityGraphFeatureStateTest {
    
    func createDiaries(_ params: (id: UUID, date: Date, isAchieved: Bool)...) -> [DiaryData] {
        
        return params.map {
            
            return .create(id: $0.id, date: $0.date, goals: [.create(isAchieved: $0.isAchieved)])
        }
    }
}
