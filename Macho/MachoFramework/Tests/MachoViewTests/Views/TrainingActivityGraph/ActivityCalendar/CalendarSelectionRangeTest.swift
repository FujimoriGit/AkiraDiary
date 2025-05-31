//
//  MachoFramework
//
//  CalendarSelectionRangeTest.swift
//
//  Created by stotic-dev on 2025/01/25
//  Copyright © Macho All rights reserved.
//

import Testing
import Foundation
@testable import MachoView

@Suite("カレンダー画面の選択範囲の振る舞いに関するテスト")
struct CalendarSelectionRangeTest {
    
    // MARK: - 正常系
    
    @Test(
        "現在の表示日が更新する表示可能期間に含まれる場合は、表示可能期間、表示日(アニメーションで)の順で更新する",
        arguments: [
            TestParamAsUpdateSelectionRange.makeAsNormalCase(
                .init(start: .distantPast,
                      end: .create(year: 2025, month: 1, day: 1)),
                .createDay(year: 1970, month: 1, day: 1)
            ),
            TestParamAsUpdateSelectionRange.makeAsNormalCase(
                .init(start: .create(year: 2025, month: 1, day: 1),
                      end: .distantFuture),
                .createDay(year: 2027, month: 1, day: 1)
            )
        ]
    )
    func 現在の表示日が含まれる表示期間に更新する(
        param: TestParamAsUpdateSelectionRange
    ) throws {
        
        let sut = CalendarSelectionRange(visibleComponents: param.initialVisibleDate,
                                         availableDateRange: param.initialAvailableRange,
                                         calendar: .current)
        
        let result = sut.makeSelectionRangeUpdateEvents(
            param.updateRange,
            param.updateVisibleDate
        )
        
        #expect(result == param.expected)
    }
    
    @Test(
        "現在の表示日が更新する表示可能期間に含まれない場合は、表示日を更新後(現在の表示日から見て更新後の表示期間の直近の日付)、通常通り表示日と期間を更新する.",
        .tags(),
        arguments: [
            TestParamAsUpdateSelectionRange.makeAsBeforeUpdateVisibleDateCase(
                initialAvailableRange: .init(start: .create(year: 2025, month: 1, day: 1),
                                             end: .create(year: 2026, month: 1, day: 1)),
                initialVisibleDate: .createDay(year: 2025, month: 2, day: 1),
                updateVisibleDate: .createDay(year: 1970, month: 1, day: 1),
                updateRange: .init(start: .distantPast,
                                   end: .create(year: 2025, month: 1, day: 1)),
                tempUpdateVisibleDate: .createMonth(year: 2025, month: 1)
            ),
            TestParamAsUpdateSelectionRange.makeAsBeforeUpdateVisibleDateCase(
                initialAvailableRange: .init(start: .create(year: 2025, month: 1, day: 1),
                                             end: .create(year: 2026, month: 1, day: 1)),
                initialVisibleDate: .createDay(year: 2025, month: 2, day: 1),
                updateVisibleDate: .createDay(year: 2027, month: 1, day: 1),
                updateRange: .init(start: .create(year: 2026, month: 1, day: 1),
                                   end: .distantFuture),
                tempUpdateVisibleDate: .createMonth(year: 2026, month: 1)
            )
        ]
    )
    func 現在の表示日が含まれない表示期間に更新する(param: TestParamAsUpdateSelectionRange) {
        
        let sut = CalendarSelectionRange(visibleComponents: param.initialVisibleDate,
                                         availableDateRange: param.initialAvailableRange,
                                         calendar: .current)
        
        let result = sut.makeSelectionRangeUpdateEvents(
            param.updateRange,
            param.updateVisibleDate
        )
        
        #expect(result == param.expected)
    }
    
    @Test(
        "更新する表示期間が現在の表示期間外の場合は、表示期間を更新(現在の表示日〜現在の表示日から見て更新後の表示期間の直近の日付)して、表示日を更新後(現在の表示日から見て更新後の表示期間の直近の日付)、通常通り表示日と期間を更新する.",
        .tags(),
        arguments: [
            TestParamAsUpdateSelectionRange.makeAsBeforeUpdateAvailableRangeToVisibleDateCase(
                initialAvailableRange: .init(start: .create(year: 2025, month: 1, day: 1),
                                             end: .create(year: 2026, month: 1, day: 1)),
                initialVisibleDate: .createDay(year: 2025, month: 2, day: 1),
                updateVisibleDate: .createDay(year: 1970, month: 1, day: 1),
                updateRange: .init(start: .distantPast,
                                   end: .create(year: 2024, month: 12, day: 31)),
                tempUpdateAvailableRange: .init(
                    start: .create(year: 2024, month: 12, day: 31),
                    end: .create(year: 2025, month: 2, day: 1)
                ),
                tempUpdateVisibleDate: .createMonth(year: 2024, month: 12)
            ),
            TestParamAsUpdateSelectionRange.makeAsBeforeUpdateAvailableRangeToVisibleDateCase(
                initialAvailableRange: .init(start: .create(year: 2025, month: 1, day: 1),
                                             end: .create(year: 2026, month: 1, day: 1)),
                initialVisibleDate: .createDay(year: 2025, month: 2, day: 1),
                updateVisibleDate: .createDay(year: 2027, month: 1, day: 1),
                updateRange: .init(start: .create(year: 2026, month: 1, day: 2),
                                   end: .distantFuture),
                tempUpdateAvailableRange: .init(
                    start: .create(year: 2025, month: 2, day: 1),
                    end: .create(year: 2026, month: 1, day: 2)
                ),
                tempUpdateVisibleDate: .createMonth(year: 2026, month: 1)
            )
        ]
    )
    func 現在の表示期間から外れた期間に更新する(param: TestParamAsUpdateSelectionRange) {
        
        let sut = CalendarSelectionRange(visibleComponents: param.initialVisibleDate,
                                         availableDateRange: param.initialAvailableRange,
                                         calendar: .current)
        
        let result = sut.makeSelectionRangeUpdateEvents(
            param.updateRange,
            param.updateVisibleDate
        )
        
        #expect(result == param.expected)
    }
    
    // MARK: - 異常系
    
    @Test(
        arguments: [
            TestParamAsUpdateSelectionRange.makeAsAbnormalCase(
                .init(start: .distantPast,
                      end: .create(year: 2025, month: 1, day: 1)),
                .createDay(year: 2025, month: 1, day: 2)
            ),
            TestParamAsUpdateSelectionRange.makeAsAbnormalCase(
                .init(start: .create(year: 2025, month: 1, day: 1),
                      end: .distantFuture),
                .createDay(year: 2024, month: 12, day: 31)
            )
        ]
    )
    func 表示日の更新する日付が更新後の表示期間外の場合は表示日は更新しない(
        param: TestParamAsUpdateSelectionRange
    ) throws {
        
        let sut = CalendarSelectionRange(visibleComponents: param.initialVisibleDate,
                                         availableDateRange: param.initialAvailableRange,
                                         calendar: .current)
        
        let result = sut.makeSelectionRangeUpdateEvents(
            param.updateRange,
            param.updateVisibleDate
        )
        
        #expect(result == param.expected)
    }
}

extension CalendarSelectionRangeTest {
    
    struct TestParamAsUpdateSelectionRange {
        
        var initialAvailableRange = DateInterval(
            start: .create(year: 2025, month: 1, day: 1),
            end: .create(year: 2025, month: 12, day: 31)
        )
        var initialVisibleDate = DateComponents(year: 2025, month: 1)
        let updateVisibleDate: DateComponents
        let updateRange: DateInterval
        let expected: [CalendarSelectionRange.UpdateEvent]
        
        static func makeAsNormalCase(_ updateRange: DateInterval,
                                     _ updateVisibleDate: DateComponents) -> Self {
            
            return .init(
                updateVisibleDate: updateVisibleDate,
                updateRange: updateRange,
                expected: [
                    .availableDateRange(updateRange),
                    .visibleDateComponentsWithAnimation(updateVisibleDate)
                ]
            )
        }
        
        static func makeAsBeforeUpdateVisibleDateCase(
            initialAvailableRange: DateInterval,
            initialVisibleDate: DateComponents,
            updateVisibleDate: DateComponents,
            updateRange: DateInterval,
            tempUpdateVisibleDate: DateComponents
        ) -> Self {
            
            return .init(
                initialAvailableRange: initialAvailableRange,
                initialVisibleDate: initialVisibleDate,
                updateVisibleDate: updateVisibleDate,
                updateRange: updateRange,
                expected: [
                    .visibleDateComponents(            tempUpdateVisibleDate),
                    .availableDateRange(updateRange),
                    .visibleDateComponentsWithAnimation(updateVisibleDate)
                ]
            )
        }
        
        static func makeAsBeforeUpdateAvailableRangeToVisibleDateCase(
            initialAvailableRange: DateInterval,
            initialVisibleDate: DateComponents,
            updateVisibleDate: DateComponents,
            updateRange: DateInterval,
            tempUpdateAvailableRange: DateInterval,
            tempUpdateVisibleDate: DateComponents
        ) -> Self {
            
            return .init(
                initialAvailableRange: initialAvailableRange,
                initialVisibleDate: initialVisibleDate,
                updateVisibleDate: updateVisibleDate,
                updateRange: updateRange,
                expected: [
                    .availableDateRange(tempUpdateAvailableRange),
                    .visibleDateComponents(tempUpdateVisibleDate),
                    .availableDateRange(updateRange),
                    .visibleDateComponentsWithAnimation(updateVisibleDate)
                ]
            )
        }
        
        static func makeAsAbnormalCase(_ updateRange: DateInterval,
                                       _ updateVisibleDate: DateComponents) -> Self {
            
            return .init(
                updateVisibleDate: updateVisibleDate,
                updateRange: updateRange,
                expected: [
                    .availableDateRange(updateRange)
                ]
            )
        }
    }
}
