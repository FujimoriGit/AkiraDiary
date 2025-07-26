//
//  MachoFramework
//
//  TotalTrainingResultTest.swift
//
//  Created by stotic-dev on 2025/07/05
//  Copyright © Macho All rights reserved.
//

import Foundation
import Testing

@testable import MachoView

struct TotalTrainingResultTest {

    @Test(arguments: [
        (Date.create(year: 2025, month: 1, day: 1, hour: 14), "02:00:00"),
        (Date.create(year: 2025, month: 1, day: 1, hour: 12, second: 40), "00:00:40")
    ])
    func 終了済みのトレーニング結果では総トレーニング時間も表示する(endTime: Date, expectedDuration: String) async throws {
        let target = TotalTrainingResult(
            .create(
                date: .create(year: 2025, month: 1, day: 1, hour: 12),
                endTime: endTime
            )
        )
        
        #expect(target.startDateDisplayText == "2025年1月1日")
        #expect(target.totalTrainingTimeDurationText == expectedDuration)
        #expect(target.trainingCount == 0)
    }

    @Test func トレーニング未完了時はデフォルト文言を表示する() async throws {
        let target = TotalTrainingResult(
            .create(
                date: .create(year: 2025, month: 1, day: 1, hour: 12),
                endTime: nil
            )
        )
        #expect(target.startDateDisplayText == "2025年1月1日")
        #expect(target.totalTrainingTimeDurationText == "まだ記録されていません")
        #expect(target.trainingCount == 0)
    }

}
