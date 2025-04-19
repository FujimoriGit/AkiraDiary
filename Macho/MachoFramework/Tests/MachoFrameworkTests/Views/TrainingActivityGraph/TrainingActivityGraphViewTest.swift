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
    
    // MARK: - 正常系
    
    func test_画面表示時に保存しているフィルターを画面に反映してフィルターに該当するアクティビティ情報を表示する() async throws {
        
        // 準備
        
        let initialStartPeriod = Date.create(year: 2024, month: 7, day: 1)
        let initialPeriod = ActivityPeriod.month
        let initialSelectedTrainingTypeList: [TrainingTypeData] = [.abs]
                
        let expectedFetchDiaryData1 = Diary.create(
            date: .create(year: 2024, month: 7, day: 1),
            goals: [.create(trainingType: .abs)]
        )
        let expectedFetchDiaryData2 = Diary.create(
            date: .create(year: 2024, month: 7, day: 2),
            goals: [.create(trainingType: .benchPress)]
        )
        
        let testStore = TestStore(initialState: TrainingActivityGraphFeature.State(),
                                  reducer: { TrainingActivityGraphFeature() },
                                  withDependencies: {
            
            $0.diaryListFetchApi = .createCustomValue(createDiaryListFetchApiRealmMock(
                expectedFetchResult: [
                    .init(expectedFetchDiaryData1),
                    .init(expectedFetchDiaryData2)
                ]
            ))
            $0.trainingTypeApi = .createCustomValue(createTrainingTypeApiRealmMock(
                expectedFetchResult: [.abs, .benchPress]
            ))
            $0.defaultAppStorage = createTestUserDefaults(
                initialStartDate: initialStartPeriod,
                initialPeriod: initialPeriod,
                initialTrainingTypeList: initialSelectedTrainingTypeList
            )
        })
        
        // 実行
        
        await testStore.send(.onAppear) {
            
            $0.activityStartPeriod = initialStartPeriod
            $0.activityPeriod = initialPeriod
            $0.calendar.displayInterval = .create(from: initialStartPeriod,
                                                  period: initialPeriod)
        }
        
        // 検証
        
        await testStore.receive(\.didReceiveTrainingTypeList) {
            
            $0.targetTrainingTypeList = [.abs]
        }
        
        await testStore.receive(\.didReceiveDiaryData) {
            
            $0.activityResultList = self.createExpectedActivityResults(
                [expectedFetchDiaryData1],
                initialStartPeriod,
                initialPeriod,
                initialSelectedTrainingTypeList
            )
            $0.calendar.decorationSources = try self.createExpectedDecorationDic(expectedFetchDiaryData1)
        }
        
        // 後始末
        
        await testStore.send(.tappedNavigationBackButton)
    }
    
    func test_フィルター表示切り替えボタンを押下するとフィルター領域の表示非表示を切り替える() async throws {
        
        let testStore = TestStore(initialState: .init(isShowingFilter: true),
                                  reducer: { TrainingActivityGraphFeature() })
        
        await testStore.send(.tappedFilterDisplayButton) {
            
            $0.isShowingFilter = false
        }
    }
    
    func test_フィルター領域を上スワイプするとフィルター領域が閉じる() async throws {
        
        let testStore = TestStore(initialState: .init(isShowingFilter: true),
                                  reducer: { TrainingActivityGraphFeature() })
        
        await testStore.send(.onDragEndedFilterArea(
            result: .init(startLocation: CGPoint(x: .zero, y: 140),
                          currentLocation: CGPoint(x: .zero, y: 90))
        )) {
            
            $0.isShowingFilter = false
        }
    }
    
    func test_カレンダーの日付押下でその日付の詳細が表示される() async throws {
        
        // 準備
        
        let expectedFetchDiaryData1 = Diary.create(
            date: .create(year: 2024, month: 6, day: 3),
            goals: [.create(trainingType: .abs)]
        )
        let initialStartPeriod = Date.create(year: 2024, month: 6, day: 3)
        let initialPeriod = ActivityPeriod.year
        
        let testState: TrainingActivityGraphFeature.State = .init(
            activityStartPeriod: initialStartPeriod,
            activityPeriod: initialPeriod,
            targetTrainingTypeList: [.abs],
            activityResultList: .init(
                [expectedFetchDiaryData1],
                periodFilter: .init(startPeriodDate: initialStartPeriod,
                                    period: initialPeriod),
                trainingTypeFilter: .init(trainingTypeList: [.abs])
            )
        )
        
        let testStore = TestStore(initialState: testState,
                                  reducer: { TrainingActivityGraphFeature() },
                                  withDependencies: {
            
            $0.defaultAppStorage = createTestUserDefaults(initialStartDate: .now)
        })
        
        // 実行
        
        await testStore.send(.calendar(.delegate(.selectedDay(.createDay(year: 2024, month: 6, day: 3))))) {
            
            // 検証
            
            let isAchieved = try XCTUnwrap(expectedFetchDiaryData1.isAchieved)
            let expectedChildState = DetailDayOfActivityFeature.State(
                targetDayStr: "2024/6/3",
                activities: [
                    .init(id: expectedFetchDiaryData1.id,
                          title: expectedFetchDiaryData1.title,
                          isAchieved: isAchieved)
                ],
                isAchieved: isAchieved)
            $0.popup = .detailDayOfActivity(.init(childState: expectedChildState))
        }
    }
    
    func test_カレンダー詳細画面で日記名をタップすると日記詳細画面へ遷移する() async throws {
        
        // 準備
        
        let expectedFetchDiaryData1 = Diary.create(
            date: .create(year: 2024, month: 6, day: 3),
            goals: [.create(trainingType: .abs)]
        )
        let initialStartPeriod = Date.create(year: 2024, month: 6, day: 3)
        let initialPeriod = ActivityPeriod.year
        
        let calendarDetailChildState = DetailDayOfActivityFeature.State(
            targetDayStr: "2024/6/3",
            activities: [
                .init(id: expectedFetchDiaryData1.id,
                      title: expectedFetchDiaryData1.title,
                      isAchieved: try XCTUnwrap(expectedFetchDiaryData1.isAchieved))
            ],
            isAchieved: try XCTUnwrap(expectedFetchDiaryData1.isAchieved))
        
        let testState: TrainingActivityGraphFeature.State = .init(
            popup: .detailDayOfActivity(.init(childState: calendarDetailChildState)),
            activityStartPeriod: initialStartPeriod,
            activityPeriod: initialPeriod,
            targetTrainingTypeList: [.abs],
            activityResultList: .init(
                [expectedFetchDiaryData1],
                periodFilter: .init(startPeriodDate: initialStartPeriod,
                                    period: initialPeriod),
                trainingTypeFilter: .init(trainingTypeList: [.abs])
            )
        )
        
        let testStore = TestStore(initialState: testState,
                                  reducer: { TrainingActivityGraphFeature() },
                                  withDependencies: {
            
            $0.defaultAppStorage = createTestUserDefaults(initialStartDate: .now)
            $0.diaryListFetchApi = .createCustomValue(createDiaryListFetchApiRealmMock(expectedFetchResult: [
                .init(expectedFetchDiaryData1),
                .create()
            ]))
        })
        
        // 実行
        
        await testStore.send(.popup(.presented(
            .detailDayOfActivity(.childAction(
                .delegate(.tappedActivityArea(diaryId: expectedFetchDiaryData1.id))
            ))
        ))) {
            
            // 検証
            
            $0.popup = nil
        }
        
        await testStore.receive(\.didReceiveDiaryDataForShowingDetail) {
            
            $0.navigationDestination = .detailScreen(.init(diary: expectedFetchDiaryData1))
        }
    }
    
    func test_表示開始日のフィルターで日時を選択したとき更新後の表示開始日と再フィルター後のアクティビティ表示期間の反映を行う() async throws {
        
        // 準備
        
        let initialStartPeriod = Date.create(year: 2024, month: 5, day: 1)
        let initialPeriod = ActivityPeriod.month
        
        let displayDiaryData = Diary.create(
            date: .create(year: 2024, month: 5, day: 1),
            goals: [.create(trainingType: .abs)]
        )
        let notDisplayDiaryData = Diary.create(
            date: .create(year: 2024, month: 5, day: 31),
            goals: [.create(trainingType: .abs)]
        )
        
        let testUserDefaults = createTestUserDefaults(initialStartDate: initialStartPeriod)
        
        let testStore = TestStore(initialState: .init(
            activityStartPeriod: initialStartPeriod,
            activityPeriod: initialPeriod
        ),
                                  reducer: { TrainingActivityGraphFeature() },
                                  withDependencies: {
            
            $0.diaryListFetchApi = .createCustomValue(
                createDiaryListFetchApiRealmMock(expectedFetchResult: [
                    .init(displayDiaryData),
                    .init(notDisplayDiaryData)
                ])
            )
            $0.defaultAppStorage = testUserDefaults
        })
        
        // 実行
        
        let selectStartPeriodDate = Date.create(year: 2024, month: 4, day: 2)
        await testStore.send(.didSelectActivityStartPeriodMenu(selectStartPeriodDate)) {
            
            // 検証
            
            $0.activityStartPeriod = selectStartPeriodDate
            $0.calendar.displayInterval = .create(from: selectStartPeriodDate,
                                                  period: initialPeriod)
        }
        
        await testStore.receive(\.didReceiveDiaryData) {
            
            $0.activityResultList = self.createExpectedActivityResults(
                [displayDiaryData, notDisplayDiaryData],
                selectStartPeriodDate,
                initialPeriod,
                []
            )
            $0.calendar.decorationSources = try self.createExpectedDecorationDic(displayDiaryData)
        }
        
        // UserDefaultsにグラフ表示開始日付の設定が正しく保存されているか確認
        XCTAssertEqual(selectStartPeriodDate.timeIntervalSince1970,
                       testUserDefaults.getDouble(.activityStartPeriod))
    }
    
    func test_フィルターの表示期間を選択したとき更新後の表示期間の日付と再フィルター後のアクティビティ表示期間の反映を行う() async throws {
        
        // 準備
        
        let initialStartPeriod = Date.create(year: 2024, month: 5, day: 1)
        let initialPeriod = ActivityPeriod.month
        
        let displayDiaryData = Diary.create(
            date: .create(year: 2024, month: 5, day: 1),
            goals: [.create(trainingType: .abs)]
        )
        let notDisplayDiaryData = Diary.create(
            date: .create(year: 2024, month: 5, day: 31),
            goals: [.create(trainingType: .abs)]
        )
        
        
        let testUserDefaults = createTestUserDefaults(initialStartDate: initialStartPeriod,
                                                      initialPeriod: initialPeriod)
        let testStore = TestStore(initialState: .init(
            activityStartPeriod: initialStartPeriod,
            activityPeriod: initialPeriod
        ),
                                  reducer: { TrainingActivityGraphFeature() },
                                  withDependencies: {
            
            $0.diaryListFetchApi = .createCustomValue(createDiaryListFetchApiRealmMock(expectedFetchResult: [
                .init(displayDiaryData),
                .init(notDisplayDiaryData)
            ]))
            $0.defaultAppStorage = testUserDefaults
        })
        
        // 実行
        
        let selectedActivityPeriod = ActivityPeriod.week
        await testStore.send(.didSelectActivityPeriodMenu(selectedActivityPeriod)) {
            
            // 検証
            
            $0.activityPeriod = selectedActivityPeriod
            $0.calendar.displayInterval = .create(from: initialStartPeriod,
                                                  period: selectedActivityPeriod)
        }
        
        await testStore.receive(\.didReceiveDiaryData) {
            
            $0.activityResultList = self.createExpectedActivityResults(
                [displayDiaryData, notDisplayDiaryData],
                initialStartPeriod,
                selectedActivityPeriod,
                []
            )
            $0.calendar.decorationSources = try self.createExpectedDecorationDic(displayDiaryData)
        }
        
        // UserDefaultsにグラフ表示期間の設定が正しく保存されているか確認
        XCTAssertEqual(selectedActivityPeriod.rawValue,
                       testUserDefaults.getInt(.activityPeriod))
    }
    
    func test_フィルターのトレーニング種目押下でトレーニング種目フィルター選択画面を表示する() async throws {
        
        let testStore = TestStore(initialState: TrainingActivityGraphFeature.State(),
                                  reducer: { TrainingActivityGraphFeature() })
        
        await testStore.send(.tappedTargetTrainingTypeMenu) {
            
            $0.popup = .selectTraining(
                .init(childState: .init(selectingTrainingTypeList: []))
            )
        }
    }
    
    func test_トレーニング種目フィルター選択画面非表示時に選択したトレーニング種目と再フィルター後のアクティビティ表示期間の反映を行う() async throws {
        
        // 準備
        
        let initialStartPeriod = Date.create(year: 2024, month: 5, day: 1)
        let initialPeriod = ActivityPeriod.month
        let initialTrainingTypeList: [TrainingTypeData] = [.abs]
        
        let displayDiaryData = Diary.create(
            date: .create(year: 2024, month: 5, day: 1),
            goals: [.create(trainingType: .abs), .create(trainingType: .benchPress)]
        )
        let notDisplayDiaryData = Diary.create(
            date: .create(year: 2024, month: 5, day: 31),
            goals: [.create(trainingType: .abs)]
        )
        
        let testUserDefaults = createTestUserDefaults(
            initialStartDate: initialStartPeriod,
            initialPeriod: initialPeriod,
            initialTrainingTypeList: initialTrainingTypeList
        )
        
        let testState: TrainingActivityGraphFeature.State = .init(
            popup: .selectTraining(.init(
                childState: .init(selectingTrainingTypeList: [.abs])
            )),
            activityStartPeriod: initialStartPeriod,
            activityPeriod: initialPeriod,
            targetTrainingTypeList: initialTrainingTypeList
        )
        let testStore = TestStore(initialState: testState,
                                  reducer: { TrainingActivityGraphFeature() },
                                  withDependencies: {
            
            $0.diaryListFetchApi = .createCustomValue(createDiaryListFetchApiRealmMock(
                expectedFetchResult: [
                    .init(displayDiaryData),
                    .init(notDisplayDiaryData)
                ]
            ))
            $0.defaultAppStorage = testUserDefaults
        })
        
        // 実行
        
        let selectedTrainingTypeList: [TrainingTypeData] = [.benchPress]
        await testStore.send(.popup(.presented(.selectTraining(.childAction(
            .delegate(.selectedTrainingTypeList(selectedTrainingTypeList))
        ))))) {
            
            // 検証
            
            $0.targetTrainingTypeList = selectedTrainingTypeList
        }
        
        await testStore.receive(\.didReceiveDiaryData) {
            
            $0.activityResultList = self.createExpectedActivityResults(
                [displayDiaryData, notDisplayDiaryData],
                initialStartPeriod,
                initialPeriod,
                selectedTrainingTypeList
            )
            $0.calendar.decorationSources = try self.createExpectedDecorationDic(displayDiaryData)
        }
        
        // UserDefaultsにグラフ表示期間の設定が正しく保存されているか確認
        XCTAssertEqual(selectedTrainingTypeList.map { $0.id.uuidString },
                       testUserDefaults.getStringArray(.targetTrainingTypeList))
    }
    
    func test_戻るボタンを押下すると前画面へ戻る() async throws {
        
        let isDismissInvoked = LockIsolated(false)
        let testStore = TestStore(initialState: .init(),
                                  reducer: { TrainingActivityGraphFeature() },
                                  withDependencies: {
            
            $0.dismiss = .init { isDismissInvoked.setValue(true) }
        })
        
        await testStore.send(.tappedNavigationBackButton)
        
        XCTAssertTrue(isDismissInvoked.value)
    }
    
    // MARK: - 異常系
    
    func test_画面表示中に日記が登録されていない場合はアラートを表示する() async throws {
        
        // 準備
        
        let initialStartPeriod = Date.create(year: 2024, month: 7, day: 1)
        let initialPeriod = ActivityPeriod.month
        
        let testStore = TestStore(initialState: TrainingActivityGraphFeature.State(),
                                  reducer: { TrainingActivityGraphFeature() },
                                  withDependencies: {
            
            $0.diaryListFetchApi = .createCustomValue(createDiaryListFetchApiRealmMock(
                expectedFetchResult: []
            ))
            $0.trainingTypeApi = .createCustomValue(createTrainingTypeApiRealmMock(
                expectedFetchResult: []
            ))
            $0.defaultAppStorage = createTestUserDefaults(
                initialStartDate: initialStartPeriod,
                initialPeriod: initialPeriod
            )
        })
        
        // 実行
        
        await testStore.send(.onAppear) {
            
            $0.activityStartPeriod = initialStartPeriod
            $0.activityPeriod = initialPeriod
            $0.calendar.displayInterval = .create(from: initialStartPeriod,
                                                  period: initialPeriod)
        }
        
        // 検証
        
        await testStore.receive(\.didReceiveTrainingTypeList)
        
        await testStore.receive(\.didReceiveDiaryData) {
            
            $0.alert = .createAlertState(.emptyDiaryItemAlert,
                                         firstButtonHandler: .emptyActivityData)
        }
        
        // 後始末
        
        await testStore.send(.tappedNavigationBackButton)
    }
    
    func test_日記が登録されていないアラートのボタンを押下するとボタンを押下された処理を親画面へ伝える() async throws {
        
        // 準備
        
        let alert = AlertState<TrainingActivityGraphFeature.Action.Alert>.createAlertState(
            .emptyDiaryItemAlert,
            firstButtonHandler: .emptyActivityData
        )
        let testStore = TestStore(
            initialState: TrainingActivityGraphFeature.State(alert: alert),
            reducer: { TrainingActivityGraphFeature() }
        )
        
        // 実行
        
        await testStore.send(.alert(.presented(.emptyActivityData))) {
            
            // 検証
            
            $0.alert = nil
        }
        
        await testStore.receive(.delegate(.tappedEmptyDiaryAlertButton))
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
    
    func createExpectedDecorationDic(_ expectedDiary: Diary) throws -> [ActivityResultDecorationSource] {
        
        let diaryDateComponents = Calendar.current.dateComponents([.year, .month, .day],
                                                                  from: expectedDiary.createdAt)
        let resultDateComponents = DateComponents.createDay(
            year: diaryDateComponents.year!,
            month: diaryDateComponents.month!,
            day: diaryDateComponents.day!
        )
        let decorationResultOfDay = ActivityResultOfDay(
            targetDate: resultDateComponents,
            activities: [
                .init(id: expectedDiary.id,
                      title: expectedDiary.title,
                      isAchieved: try XCTUnwrap(expectedDiary.isAchieved))
            ]
        )
        
        return [
            .init(
                isAchievedOfDay: decorationResultOfDay.isAchieved,
                targetDay: resultDateComponents
            )
        ]
    }
    
    func createExpectedActivityResults(_ expectedDiaries: [Diary],
                                       _ expectedStartPeriodDate: Date,
                                       _ expectedPeriod: ActivityPeriod,
                                       _ expectedTrainingFilter: [TrainingTypeData]) -> ActivityResults {
        
        return .init(
            expectedDiaries,
            periodFilter: .init(startPeriodDate: expectedStartPeriodDate,
                                period: expectedPeriod),
            trainingTypeFilter: .init(trainingTypeList: expectedTrainingFilter)
        )
    }
}
