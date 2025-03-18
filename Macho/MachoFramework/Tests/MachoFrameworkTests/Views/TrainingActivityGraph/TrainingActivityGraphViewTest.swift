//
//  TrainingActivityGraphViewTest.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/24.
//

import ComposableArchitecture
import XCTest

@testable import MachoView

@MainActor
final class TrainingActivityGraphViewTest: XCTestCase {
    
    // MARK: - test data definition
    
    private static let absTraining = TrainingTypeData(id: UUID(), name: "腹筋")
    private static let benchPressTraining = TrainingTypeData(id: UUID(), name: "ベンチプレス")
    private static let pushUpTraining = TrainingTypeData(id: UUID(), name: "腕立て")
    
    private static let absTrainingContent = TrainingContentData(id: UUID(),
                                                                trainingType: absTraining,
                                                                goalNumberOfSets: 3,
                                                                goalSetCount: 3,
                                                                actualNumberOfSets: 3,
                                                                actualSetCount: 3)
    private static let benchPressTrainingContent = TrainingContentData(id: UUID(),
                                                                       trainingType: absTraining,
                                                                       goalNumberOfSets: 3,
                                                                       goalSetCount: 3,
                                                                       actualNumberOfSets: 1,
                                                                       actualSetCount: 1)
    
    private static let pushUpTrainingContent = TrainingContentData(id: UUID(),
                                                                   trainingType: pushUpTraining,
                                                                   goalNumberOfSets: 3,
                                                                   goalSetCount: 3,
                                                                   actualNumberOfSets: 1,
                                                                   actualSetCount: 1)
    
    private static let absTrainingContentAtThreeDay = TrainingContentData(id: UUID(),
                                                                          trainingType: absTraining,
                                                                          goalNumberOfSets: 3,
                                                                          goalSetCount: 3,
                                                                          actualNumberOfSets: 3,
                                                                          actualSetCount: 3)
    
    private static let pushUpTrainingContentAtFourDay = TrainingContentData(id: UUID(),
                                                                            trainingType: pushUpTraining,
                                                                            goalNumberOfSets: 3,
                                                                            goalSetCount: 3,
                                                                            actualNumberOfSets: 1,
                                                                            actualSetCount: 1)
    
    private static let absTrainingContentAtFourDay = TrainingContentData(id: UUID(),
                                                                         trainingType: absTraining,
                                                                         goalNumberOfSets: 3,
                                                                         goalSetCount: 3,
                                                                         actualNumberOfSets: 3,
                                                                         actualSetCount: 3)
    
    private static let absTrainingContentAtFiveDay = TrainingContentData(id: UUID(),
                                                                         trainingType: absTraining,
                                                                         goalNumberOfSets: 3,
                                                                         goalSetCount: 3,
                                                                         actualNumberOfSets: 3,
                                                                         actualSetCount: 3)
    
    private static let benchPressTrainingContentAtFiveDay = TrainingContentData(
        id: UUID(),
        trainingType: benchPressTraining,
        goalNumberOfSets: 3,
        goalSetCount: 3,
        actualNumberOfSets: 1,
        actualSetCount: 1
    )
    
    private static let absTrainingContentOfNewest = TrainingContentData(id: UUID(),
                                                                        trainingType: absTraining,
                                                                        goalNumberOfSets: 3,
                                                                        goalSetCount: 3,
                                                                        actualNumberOfSets: 3,
                                                                        actualSetCount: 3)
    private static let benchPressTrainingContentOfNewest = TrainingContentData(
        id: UUID(),
        trainingType: benchPressTraining,
        goalNumberOfSets: 3,
        goalSetCount: 3,
        actualNumberOfSets: 1,
        actualSetCount: 1)
    
    private static let sampleDiaryData = DiaryData(id: UUID(),
                                                   date: getSelectDate(year: 2024,
                                                                       month: 6,
                                                                       day: 1),
                                                   title: "sampleDiaryData",
                                                   mainText: "sampleDiaryData message",
                                                   goals: [absTrainingContent],
                                                   tags: [],
                                                   startTime: getSelectDate(year: 2024,
                                                                            month: 6,
                                                                            day: 1,
                                                                            hour: 10),
                                                   endTime: getSelectDate(year: 2024,
                                                                          month: 6,
                                                                          day: 1,
                                                                          hour: 18))
    
    private static let sampleDiaryData2 = DiaryData(id: UUID(),
                                                    date: getSelectDate(year: 2024,
                                                                        month: 6,
                                                                        day: 2),
                                                    title: "sampleDiaryData2",
                                                    mainText: "sampleDiaryData2 message",
                                                    goals: [benchPressTrainingContent],
                                                    tags: [],
                                                    startTime: getSelectDate(year: 2024,
                                                                             month: 6,
                                                                             day: 2,
                                                                             hour: 14),
                                                    endTime: getSelectDate(year: 2024,
                                                                           month: 6,
                                                                           day: 2,
                                                                           hour: 20))
    
    private static let sampleDiaryData3 = DiaryData(id: UUID(),
                                                    date: getSelectDate(year: 2025,
                                                                        month: 6,
                                                                        day: 30),
                                                    title: "sampleDiaryData3",
                                                    mainText: "sampleDiaryData3 message",
                                                    goals: [
                                                        absTrainingContentOfNewest,
                                                        benchPressTrainingContentOfNewest
                                                    ],
                                                    tags: [],
                                                    startTime: getSelectDate(year: 2025,
                                                                             month: 6,
                                                                             day: 30,
                                                                             hour: 10),
                                                    endTime: getSelectDate(year: 2025,
                                                                           month: 6,
                                                                           day: 30,
                                                                           hour: 18))
    
    private static let sampleDiaryData4 = DiaryData(id: UUID(),
                                                    date: getSelectDate(year: 2024,
                                                                        month: 6,
                                                                        day: 3),
                                                    title: "sampleDiaryData4",
                                                    mainText: "sampleDiaryData4 message",
                                                    goals: [
                                                        pushUpTrainingContent,
                                                        absTrainingContentAtThreeDay
                                                    ],
                                                    tags: [],
                                                    startTime: getSelectDate(year: 2024,
                                                                             month: 6,
                                                                             day: 3,
                                                                             hour: 9),
                                                    endTime: getSelectDate(year: 2024,
                                                                           month: 6,
                                                                           day: 3,
                                                                           hour: 10))
    
    private static let sampleDiaryData5 = DiaryData(id: UUID(),
                                                    date: getSelectDate(year: 2024,
                                                                        month: 6,
                                                                        day: 4),
                                                    title: "sampleDiaryData5",
                                                    mainText: "sampleDiaryData5 message",
                                                    goals: [
                                                        pushUpTrainingContentAtFourDay,
                                                    ],
                                                    tags: [],
                                                    startTime: getSelectDate(year: 2024,
                                                                             month: 6,
                                                                             day: 4,
                                                                             hour: 9),
                                                    endTime: getSelectDate(year: 2024,
                                                                           month: 6,
                                                                           day: 4,
                                                                           hour: 10))
    
    private static let sampleDiaryData6 = DiaryData(id: UUID(),
                                                    date: getSelectDate(year: 2024,
                                                                        month: 6,
                                                                        day: 4),
                                                    title: "sampleDiaryData6",
                                                    mainText: "sampleDiaryData6 message",
                                                    goals: [
                                                        absTrainingContentAtFourDay,
                                                    ],
                                                    tags: [],
                                                    startTime: getSelectDate(year: 2024,
                                                                             month: 6,
                                                                             day: 4,
                                                                             hour: 9),
                                                    endTime: getSelectDate(year: 2024,
                                                                           month: 6,
                                                                           day: 4,
                                                                           hour: 10))
    
    private static let sampleDiaryData7 = DiaryData(id: UUID(),
                                                    date: getSelectDate(year: 2024,
                                                                        month: 6,
                                                                        day: 5),
                                                    title: "sampleDiaryData7",
                                                    mainText: "sampleDiaryData7 message",
                                                    goals: [absTrainingContentAtFiveDay],
                                                    tags: [],
                                                    startTime: getSelectDate(year: 2024,
                                                                             month: 6,
                                                                             day: 5,
                                                                             hour: 9),
                                                    endTime: getSelectDate(year: 2024,
                                                                           month: 6,
                                                                           day: 5,
                                                                           hour: 10))
    
    private static let sampleDiaryData8 = DiaryData(id: UUID(),
                                                    date: getSelectDate(year: 2024,
                                                                        month: 6,
                                                                        day: 5),
                                                    title: "sampleDiaryData8",
                                                    mainText: "sampleDiaryData8 message",
                                                    goals: [benchPressTrainingContentAtFiveDay],
                                                    tags: [],
                                                    startTime: getSelectDate(year: 2024,
                                                                             month: 6,
                                                                             day: 5,
                                                                             hour: 9),
                                                    endTime: getSelectDate(year: 2024,
                                                                           month: 6,
                                                                           day: 5,
                                                                           hour: 10))
}

extension TrainingActivityGraphViewTest {
    
    // MARK: - 正常系
    
    /// 初回グラフ画面表示時の挙動を確認
    ///
    /// # 確認仕様
    /// - 画面表示時に以下デフォルト値の開始日付、グラフ表示期間、対象トレーニング種目を画面表示する
    ///   - 開始日付: 現在月の月初
    ///   - 表示期間: 1ヶ月
    ///   - 対象トレーニング種目: すべて
    /// - カレンダーに一日単位で表示するアクティビティ結果の勝ち負けのアイコンは以下で決定する
    ///   - その日にアクティビティ(日記)が1件のみの場合は、その日記の勝ち負けで決定する
    ///   - アクティビティ(日記)が複数件の場合は、全てのアクティビティが勝ちであれば勝ち、それ以外は負けとする
    func testOnAppearWithInitial() async throws {
        
        let initialStartPeriod = Self.getSelectDate(year: 2024, month: 6, day: .zero)
        let expectedTrainingTypeList = [
            Self.absTraining,
            Self.benchPressTraining,
            Self.pushUpTraining
        ]
        
        let expectedFetchDiaryData1 = Self.sampleDiaryData
        let expectedFetchDiaryData2 = Self.sampleDiaryData2
        let expectedFetchDiaryData3 = Self.sampleDiaryData3
        let expectedFetchDiaryData4 = Self.sampleDiaryData4
        let expectedFetchDiaryData5 = Self.sampleDiaryData5
        let expectedFetchDiaryData6 = Self.sampleDiaryData6
        let expectedFetchDiaryData7 = Self.sampleDiaryData7
        let expectedFetchDiaryData8 = Self.sampleDiaryData8
        
        let testStore = TestStore(initialState: TrainingActivityGraphFeature.State(),
                                  reducer: { TrainingActivityGraphFeature() },
                                  withDependencies: {
            
            $0.diaryListFetchApi = .createCustomValue(createDiaryListFetchApiRealmMock(expectedFetchResult: [
                expectedFetchDiaryData1,
                expectedFetchDiaryData2,
                expectedFetchDiaryData3,
                expectedFetchDiaryData4,
                expectedFetchDiaryData5,
                expectedFetchDiaryData6,
                expectedFetchDiaryData7,
                expectedFetchDiaryData8,
            ]))
            $0.trainingTypeApi = .createCustomValue(createTrainingTypeApiRealmMock(expectedFetchResult: expectedTrainingTypeList))
            $0.defaultAppStorage = createTestUserDefaults(initialStartDate: initialStartPeriod)
        })
        
        await testStore.send(.onAppear) {
            
            $0 = .init(activityStartPeriod: initialStartPeriod,
                       activityPeriod: .week,
                       targetTrainingTypeList: [],
                       activityResultList: .init(resultList: []))
        }
        
        // TODO: 実装できたらコメントアウト外す
        await testStore.receive(\.didReceiveTrainingTypeList)
        
        //        await testStore.receive(\.didReceiveDiaryData) {
        //
        //            $0.viewState = .init(activityStartPeriod: initialStartPeriod,
        //                                 activityPeriod: .week,
        //                                 targetTrainingTypeList: expectedTrainingTypeList,
        //                                 activityResultList: .init(resultList: [
        //                                    .init(targetDate: expectedFetchDiaryData1.date,
        //                                          isAchieved: true,
        //                                          activities: [.init(id: expectedFetchDiaryData1.id,
        //                                                             title: expectedFetchDiaryData1.title,
        //                                                             isAchieved: true)]),
        //                                    .init(targetDate: expectedFetchDiaryData2.date,
        //                                          isAchieved: false,
        //                                          activities: [.init(id: expectedFetchDiaryData2.id,
        //                                                             title: expectedFetchDiaryData2.title,
        //                                                             isAchieved: false)]),
        //                                    .init(targetDate: expectedFetchDiaryData4.date,
        //                                          isAchieved: true,
        //                                          activities: [.init(id: expectedFetchDiaryData4.id,
        //                                                             title: expectedFetchDiaryData4.title,
        //                                                             isAchieved: true)]),
        //                                    .init(targetDate: expectedFetchDiaryData5.date,
        //                                          isAchieved: false,
        //                                          activities: [.init(id: expectedFetchDiaryData5.id,
        //                                                             title: expectedFetchDiaryData5.title,
        //                                                             isAchieved: false)]),
        //                                    .init(targetDate: expectedFetchDiaryData7.date,
        //                                          isAchieved: false,
        //                                          activities: [
        //                                            .init(id: expectedFetchDiaryData7.id,
        //                                                             title: expectedFetchDiaryData7.title,
        //                                                             isAchieved: true),
        //                                            .init(id: expectedFetchDiaryData8.id,
        //                                                             title: expectedFetchDiaryData8.title,
        //                                                             isAchieved: false)
        //                                          ])
        //                                 ]))
        //        }
        
        await testStore.send(.tappedFilterDisplayButton) {
            
            $0.isShowingFilter = false
        }
        
        await testStore.send(.tappedFilterDisplayButton) {
            
            $0.isShowingFilter = true
        }
        
        await testStore.send(.onDragEndedFilterArea(result: .init(startLocation: CGPoint(x: .zero, y: 140),
                                                                  currentLocation: CGPoint(x: .zero, y: 90)))) {
            
            $0.isShowingFilter = false
        }
        
        await testStore.send(.onDragEndedFilterArea(result: .init(startLocation: CGPoint(x: .zero, y: 90),
                                                                  currentLocation: CGPoint(x: .zero, y: 140)))) {
            
            $0.isShowingFilter = true
        }
    }
    
    /// カレンダーの日付タップ時の挙動を確認
    ///
    /// # 確認仕様
    /// - 画面表示時に前回設定した開始日付、グラフ表示期間、対象トレーニング種目を取得して画面表示する
    /// - 開始日付、グラフ表示期間、対象トレーニング種目を取得したら以下処理を行う
    ///   - デフォルトのフィルターに当てはまる日記データを取得する
    ///   - 取得した日記データからカレンダーの日付アイテムに変換して日付の昇順にソートする
    ///   - アクティビティ結果を更新して目標達成率と時間帯で表示する
    /// - カレンダーの日付タップで表示されるアクティビティ一覧をタップした時、詳細画面へ遷移する
    func testTappedDayItemOfCalendar() async throws {
        
        // dismiss確認用のオブジェクト生成
        let isDismissInvoked = LockIsolated(false)
        
        let initialStartPeriod = Self.getSelectDate(year: 2024, month: 6, day: 3)
        let expectedTrainingTypeList = [
            Self.absTraining,
            Self.benchPressTraining
        ]
        
        let expectedFetchDiaryData1 = Self.sampleDiaryData
        let expectedFetchDiaryData2 = Self.sampleDiaryData2
        let expectedFetchDiaryData3 = Self.sampleDiaryData3
        
        let testStore = TestStore(initialState: TrainingActivityGraphFeature.State(),
                                  reducer: { TrainingActivityGraphFeature() },
                                  withDependencies: {
            
            $0.dismiss = .init { isDismissInvoked.setValue(true) }
            $0.diaryListFetchApi = .createCustomValue(createDiaryListFetchApiRealmMock(expectedFetchResult: [
                expectedFetchDiaryData1,
                expectedFetchDiaryData2,
                expectedFetchDiaryData3,
            ]))
            $0.trainingTypeApi = .createCustomValue(createTrainingTypeApiRealmMock(expectedFetchResult: expectedTrainingTypeList))
            $0.defaultAppStorage = createTestUserDefaults(initialStartDate: initialStartPeriod,
                                                          initialPeriod: .year,
                                                          initialTrainingTypeList: [Self.absTraining])
        })
        
        await testStore.send(.onAppear) {
            
            $0 = .init(activityStartPeriod: initialStartPeriod,
                       activityPeriod: .year,
                       targetTrainingTypeList: [],
                       activityResultList: .init(resultList: []))
        }
        
        await testStore.receive(\.didReceiveTrainingTypeList) {
            
            $0.targetTrainingTypeList = [Self.absTraining]
        }
        
        throw XCTSkip("No implementation yet.")
        
        await testStore.receive(\.didReceiveDiaryData) {
            
            $0.activityResultList = .init(resultList: [
                .init(targetDate: expectedFetchDiaryData3.date,
                      isAchieved: false,
                      activities: [.init(id: expectedFetchDiaryData3.id,
                                         title: expectedFetchDiaryData3.title,
                                         isAchieved: false)]),
            ])
        }
        
        await testStore.send(.tappedActivityCell)
        
        // 前画面に戻ったかどうかの確認
        XCTAssertTrue(isDismissInvoked.value)
    }
    
    /// グラフ表示開始日をメニューで変更した時の挙動を確認
    ///
    /// # 確認仕様
    /// - グラフ開始日付をメニューで変更すると、以下処理を行う
    ///   - グラフ開始日付を更新する
    ///   - グラフ開始日付変更後のフィルターに当てはまる日記データを取得する
    ///   - 取得した日記データからカレンダーの日付アイテムに変換して日付の昇順にソートする
    ///   - アクティビティ結果を更新して目標達成率と時間帯で表示する
    func testSelectedGraphActivityStartPeriodMenu() async throws {
        
        let initialStartPeriod = Self.getSelectDate(year: 2024, month: 5, day: 1)
        let expectedTrainingTypeList = [
            Self.absTraining,
            Self.benchPressTraining
        ]
        
        let expectedFetchDiaryData1 = Self.sampleDiaryData
        let expectedFetchDiaryData2 = Self.sampleDiaryData2
        let expectedFetchDiaryData3 = Self.sampleDiaryData3
        
        
        let testUserDefaults = createTestUserDefaults(initialStartDate: initialStartPeriod,
                                                      initialPeriod: .month,
                                                      initialTrainingTypeList: [Self.absTraining])
        let testStore = TestStore(initialState: TrainingActivityGraphFeature.State(),
                                  reducer: { TrainingActivityGraphFeature() },
                                  withDependencies: {
            
            $0.diaryListFetchApi = .createCustomValue(createDiaryListFetchApiRealmMock(expectedFetchResult: [
                expectedFetchDiaryData3,
            ]))
            $0.trainingTypeApi = .createCustomValue(createTrainingTypeApiRealmMock(expectedFetchResult: expectedTrainingTypeList))
            $0.defaultAppStorage = testUserDefaults
        })
        
        await testStore.send(.onAppear) {
            
            $0 = .init(activityStartPeriod: initialStartPeriod,
                       activityPeriod: .month,
                       targetTrainingTypeList: [],
                       activityResultList: .init(resultList: []))
        }
        
        await testStore.receive(\.didReceiveTrainingTypeList) {
            
            $0.targetTrainingTypeList = [Self.absTraining]
        }
        
        // TODO: 実装できたらコメントアウト外す
        //        await testStore.receive(\.didReceiveDiaryData) {
        //
        //            $0 = .init(activityStartPeriod: initialStartPeriod,
        //                       activityPeriod: .month,
        //                       targetTrainingTypeList: [Self.absTraining],
        //                       activityResultList: .init(resultList: []))
        //        }
        
        let expectedChangeActivityStartPeriod = Self.getSelectDate(year: 2024, month: 6, day: 1)
        
        await testStore.send(.didSelectActivityStartPeriodMenu(expectedChangeActivityStartPeriod)) {
            
            $0.activityStartPeriod = expectedChangeActivityStartPeriod
        }
        
        // UserDefaultsにグラフ表示開始日付の設定が正しく保存されているか確認
        XCTAssertEqual(expectedChangeActivityStartPeriod.timeIntervalSince1970,
                       testUserDefaults.getDouble(.activityStartPeriod))
        
        throw XCTSkip("No implementation yet.")
        
        await testStore.receive(\.didReceiveDiaryData) {
            
            $0.activityResultList = .init(resultList: [
                .init(targetDate: expectedFetchDiaryData1.date,
                      isAchieved: true,
                      activities: [.init(id: expectedFetchDiaryData1.id,
                                         title: expectedFetchDiaryData1.title,
                                         isAchieved: true)]),
            ])
        }
    }
    
    /// グラフ表示期間をメニューで変更した時の挙動を確認
    ///
    /// # 確認仕様
    /// - グラフ表示期間をメニューで変更すると、以下処理を行う
    ///   - グラフ表示期間を更新する
    ///   - グラフ開始日付変更後のフィルターに当てはまる日記データを取得する
    ///   - 取得した日記データからカレンダーの日付アイテムに変換して日付の昇順にソートする
    ///   - アクティビティ結果を更新して目標達成率と時間帯で表示する
    func testSelectedGraphActivityPeriodMenu() async throws {
        
        let initialStartPeriod = Self.getSelectDate(year: 2024, month: 5, day: 1)
        let expectedTrainingTypeList = [
            Self.absTraining,
            Self.benchPressTraining
        ]
        
        let expectedFetchDiaryData1 = Self.sampleDiaryData
        let expectedFetchDiaryData2 = Self.sampleDiaryData2
        let expectedFetchDiaryData3 = Self.sampleDiaryData3
        
        
        let testUserDefaults = createTestUserDefaults(initialStartDate: initialStartPeriod,
                                                      initialPeriod: .month,
                                                      initialTrainingTypeList: [Self.absTraining])
        let testStore = TestStore(initialState: TrainingActivityGraphFeature.State(),
                                  reducer: { TrainingActivityGraphFeature() },
                                  withDependencies: {
            
            $0.diaryListFetchApi = .createCustomValue(createDiaryListFetchApiRealmMock(expectedFetchResult: [
                expectedFetchDiaryData3,
            ]))
            $0.trainingTypeApi = .createCustomValue(createTrainingTypeApiRealmMock(expectedFetchResult: expectedTrainingTypeList))
            $0.defaultAppStorage = testUserDefaults
        })
        
        await testStore.send(.onAppear) {
            
            $0 = .init(activityStartPeriod: initialStartPeriod,
                       activityPeriod: .month,
                       targetTrainingTypeList: [],
                       activityResultList: .init(resultList: []))
        }
        
        await testStore.receive(\.didReceiveTrainingTypeList) {
            
            $0.targetTrainingTypeList = [Self.absTraining]
        }
        
        // TODO: 実装できたらコメントアウト外す
        //        await testStore.receive(\.didReceiveDiaryData) {
        //
        //            $0.viewState = .init(activityStartPeriod: initialStartPeriod,
        //                                 activityPeriod: .month,
        //                                 targetTrainingTypeList: [Self.absTraining],
        //                                 activityResultList: .init(resultList: []))
        //        }
        
        let expectedActivityPeriod: ActivityPeriod = .year
        await testStore.send(.didSelectActivityPeriodMenu(expectedActivityPeriod)) {
            
            $0.activityPeriod = expectedActivityPeriod
        }
        
        // UserDefaultsにグラフ表示期間の設定が正しく保存されているか確認
        XCTAssertEqual(expectedActivityPeriod.rawValue,
                       testUserDefaults.getInt(.activityPeriod))
        
        // TODO: 実装できたら削除する
        throw XCTSkip("No implementation yet.")
        
        await testStore.receive(\.didReceiveDiaryData) {
            
            $0.activityResultList = .init(resultList: [
                .init(targetDate: expectedFetchDiaryData1.date,
                      isAchieved: true,
                      activities: [.init(id: expectedFetchDiaryData1.id,
                                         title: expectedFetchDiaryData1.title,
                                         isAchieved: true)]),
                .init(targetDate: expectedFetchDiaryData3.date,
                      isAchieved: true,
                      activities: [.init(id: expectedFetchDiaryData3.id,
                                         title: expectedFetchDiaryData3.title,
                                         isAchieved: true)]),
            ])
        }
    }
    
    /// 対象トレーニング種目をメニューで変更した時の挙動を確認
    ///
    /// # 確認仕様
    /// - 対象トレーニング種目をメニューで変更すると、以下処理を行う
    ///   - 対象トレーニング種目を更新する
    ///   - グラフ開始日付変更後のフィルターに当てはまる日記データを取得する
    ///   - 取得した日記データからカレンダーの日付アイテムに変換して日付の昇順にソートする
    ///   - アクティビティ結果を更新して目標達成率と時間帯で表示する
    func testSelectedTargetTrainingTypeMenu() async throws {
        
        let initialStartPeriod = Self.getSelectDate(year: 2024, month: 6, day: 1)
        let expectedTrainingTypeList = [
            Self.absTraining,
            Self.benchPressTraining
        ]
        
        let expectedFetchDiaryData1 = Self.sampleDiaryData
        let expectedFetchDiaryData2 = Self.sampleDiaryData2
        let expectedFetchDiaryData3 = Self.sampleDiaryData3
        
        
        let testUserDefaults = createTestUserDefaults(initialStartDate: initialStartPeriod,
                                                      initialPeriod: .year,
                                                      initialTrainingTypeList: [Self.absTraining])
        let testStore = TestStore(initialState: TrainingActivityGraphFeature.State(),
                                  reducer: { TrainingActivityGraphFeature() },
                                  withDependencies: {
            
            $0.diaryListFetchApi = .createCustomValue(createDiaryListFetchApiRealmMock(expectedFetchResult: [
                expectedFetchDiaryData3,
            ]))
            $0.trainingTypeApi = .createCustomValue(createTrainingTypeApiRealmMock(expectedFetchResult: expectedTrainingTypeList))
            $0.defaultAppStorage = testUserDefaults
        })
        
        await testStore.send(.onAppear) {
            
            $0 = .init(activityStartPeriod: initialStartPeriod,
                       activityPeriod: .year,
                       targetTrainingTypeList: [],
                       activityResultList: .init(resultList: []))
            //            $0 = .init(activityStartPeriod: initialStartPeriod,
            //                       activityPeriod: .year,
            //                       targetTrainingTypeList: [Self.absTraining],
            //                       activityResultList: .init(resultList: []))
        }
        
        await testStore.receive(\.didReceiveTrainingTypeList) {
            
            $0 = .init(activityStartPeriod: initialStartPeriod,
                       activityPeriod: .year,
                       targetTrainingTypeList: [Self.absTraining],
                       activityResultList: .init(resultList: []))
        }
        
        // TODO: 実装できたらコメントアウト外す
        //        await testStore.receive(\.didReceiveDiaryData) {
        //
        //            $0 = .init(activityStartPeriod: initialStartPeriod,
        //                                 activityPeriod: .year,
        //                                 targetTrainingTypeList: [Self.absTraining],
        //                                 activityResultList: .init(resultList: [
        //                                    .init(targetDate: expectedFetchDiaryData1.date,
        //                                          isAchieved: true,
        //                                          activities: [.init(id: expectedFetchDiaryData1.id,
        //                                                             title: expectedFetchDiaryData1.title,
        //                                                             isAchieved: true)]),
        //                                    .init(targetDate: expectedFetchDiaryData3.date,
        //                                          isAchieved: true,
        //                                          activities: [.init(id: expectedFetchDiaryData3.id,
        //                                                             title: expectedFetchDiaryData3.title,
        //                                                             isAchieved: true)])
        //                                 ]))
        //        }
        
        let expectedChangeTrainingTypeList: [TrainingTypeData] = [
            Self.absTraining,
            Self.benchPressTraining
        ]
        
        await testStore.send(.tappedTargetTrainingTypeMenu) {
            
            $0.selectTrainingPopUp = .init(childState: .init(selectingTrainingTypeList: [Self.absTraining]))
        }
        
        await testStore.send(.selectTrainingPopUp(.presented(.childAction(.delegate(.selectedTrainingTypeList(expectedChangeTrainingTypeList)))))) {
            
            $0.targetTrainingTypeList = expectedChangeTrainingTypeList
        }
        
        await testStore.send(.selectTrainingPopUp(.dismiss)) {
            
            $0.selectTrainingPopUp = nil
        }
        
        // UserDefaultsにグラフ表示期間の設定が正しく保存されているか確認
        XCTAssertEqual(expectedChangeTrainingTypeList.map { $0.id.uuidString },
                       testUserDefaults.getStringArray(.targetTrainingTypeList))
        
        // TODO: 実装できたら削除する
        throw XCTSkip("No implementation yet.")
        
        await testStore.receive(\.didReceiveDiaryData) {
            
            $0 = .init(activityStartPeriod: initialStartPeriod,
                       activityPeriod: .year,
                       targetTrainingTypeList: expectedChangeTrainingTypeList,
                       activityResultList: .init(resultList: [
                        .init(targetDate: expectedFetchDiaryData1.date,
                              isAchieved: true,
                              activities: [.init(id: expectedFetchDiaryData1.id,
                                                 title: expectedFetchDiaryData1.title,
                                                 isAchieved: true)]),
                        .init(targetDate: expectedFetchDiaryData2.date,
                              isAchieved: false,
                              activities: [.init(id: expectedFetchDiaryData2.id,
                                                 title: expectedFetchDiaryData2.title,
                                                 isAchieved: false)]),
                        .init(targetDate: expectedFetchDiaryData3.date,
                              isAchieved: false,
                              activities: [.init(id: expectedFetchDiaryData3.id,
                                                 title: expectedFetchDiaryData3.title,
                                                 isAchieved: false)]),
                       ]))
        }
    }
    
    // MARK: - 異常系
    
    /// アクティビティ(日記データ)が0件の場合にグラフ画面表示時の挙動
    ///
    /// # 確認仕様
    /// - 日記がまだ登録されていない(フィルター抜き)旨のアラートを表示する
    /// - アラートのボタン押下でリスト画面へ戻る
    func testEmptyActivity() async throws {
        
        // dismiss確認用のオブジェクト生成
        let isDismissInvoked = LockIsolated(false)
        
        let initialStartPeriod = Self.getSelectDate(year: 2024, month: 6, day: 1)
        let expectedTrainingTypeList = [
            Self.absTraining,
            Self.benchPressTraining
        ]
        
        let testUserDefaults = createTestUserDefaults(initialStartDate: initialStartPeriod,
                                                      initialPeriod: .year,
                                                      initialTrainingTypeList: expectedTrainingTypeList)
        let testStore = TestStore(initialState: TrainingActivityGraphFeature.State(),
                                  reducer: { TrainingActivityGraphFeature() },
                                  withDependencies: {
            
            $0.dismiss = .init { isDismissInvoked.setValue(true) }
            $0.diaryListFetchApi = .createCustomValue(createDiaryListFetchApiRealmMock(expectedFetchResult: []))
            $0.trainingTypeApi = .createCustomValue(createTrainingTypeApiRealmMock(expectedFetchResult: expectedTrainingTypeList))
            $0.defaultAppStorage = testUserDefaults
        })
        
        await testStore.send(.onAppear) {
            
            $0 = .init(activityStartPeriod: initialStartPeriod,
                       activityPeriod: .year,
                       targetTrainingTypeList: [],
                       activityResultList: .init(resultList: []))
        }
        
        await testStore.receive(\.didReceiveTrainingTypeList) {
            
            $0 = .init(activityStartPeriod: initialStartPeriod,
                       activityPeriod: .year,
                       targetTrainingTypeList: expectedTrainingTypeList,
                       activityResultList: .init(resultList: []))
        }
        
        // TODO: 実装できたら削除する
        throw XCTSkip("No implementation yet.")
        
        await testStore.receive(\.didReceiveDiaryData) {
            
            $0.alert = .createAlertState(.emptyDiaryItemAlert,
                                         firstButtonHandler: .emptyActivityData)
        }
        
        await testStore.send(.alert(.presented(.emptyActivityData)))
        
        // 前画面に戻ったかどうかの確認
        XCTAssertTrue(isDismissInvoked.value)
    }
}

// MARK: - test utilities

private extension TrainingActivityGraphViewTest {
    
    func createTestUserDefaults(initialStartDate startDate: Date,
                                initialPeriod: ActivityPeriod = .week,
                                initialTrainingTypeList: [TrainingTypeData] = []) -> UserDefaults {
        
        guard let testStorage = UserDefaults(suiteName: "testOnAppearWithInitial") else {
            
            XCTFail("Failed create test UserDefaults.")
            return UserDefaults()
        }
        
        testStorage.setDouble(startDate.timeIntervalSince1970,
                              .activityStartPeriod)
        testStorage.setInt(initialPeriod.rawValue,
                           .activityPeriod)
        testStorage.setStringArray(initialTrainingTypeList.map { $0.id.uuidString },
                                   .targetTrainingTypeList)
        
        return testStorage
    }
    
    func createTrainingTypeApiRealmMock(expectedFetchResult: [TrainingTypeData]) -> RealmAccessorMock<TrainingTypeData> {
        
        return RealmAccessorMock(fetchEntity: expectedFetchResult)
    }
    
    func createDiaryListFetchApiRealmMock(expectedFetchResult: [DiaryData]) -> RealmAccessorMock<DiaryData> {
        
        return RealmAccessorMock(fetchEntity: expectedFetchResult)
    }
    
    static func getSelectDate(year: Int, month: Int, day: Int, hour: Int = .zero) -> Date {
        
        return Calendar.current.date(from: .init(year: year, month: month, day: day, hour: hour))!
    }
}
