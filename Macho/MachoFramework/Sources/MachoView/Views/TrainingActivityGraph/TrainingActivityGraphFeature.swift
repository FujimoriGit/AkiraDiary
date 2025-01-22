//
//  TrainingActivityGraphFeature.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/24.
//

import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct TrainingActivityGraphFeature {
    
    // MARK: - state definition
    
    @ObservableState
    struct State: Equatable, Sendable {
        
        // MARK: Presents States
        
        @Presents var alert: AlertState<Action.Alert>?
        @Presents var popup: PopUpDestination.State?
        
        // MARK: View State
        
        var currentActivityPeriodTitle: String {
            
            return activityPeriod.title
        }
        
        var selectingTrainingTypeNameList: [String] {
            
            return targetTrainingTypeList.map(\.name)
        }

        var isShowingFilter = true
        /// グラフ表示開始日付
        var activityStartPeriod: Date = .now
        /// グラフ表示期間
        var activityPeriod: ActivityPeriod = .week
        /// 表示トレーニングリスト
        var targetTrainingTypeList: [TrainingTypeData] = []
        /// 一日毎のアクティビティ結果
        var activityResultList: ActivityResults = .init([])
        
        // MARK: child feature state
        
        var calendar = ActivityCalendarFeature.State(displayInterval: .init(start: .now, end: .now),
                                                     calendarDecorator: .getInitial())
    }
    
    // MARK: - action definition
    
    enum Action: Equatable, Sendable {
        
        // MARK: - rooting event action
        
        case alert(PresentationAction<Alert>)
        case popup(PresentationAction<PopUpDestination.Action>)
        
        // MARK: user event action
        
        /// 画面表示時
        case onAppear
        /// グラフ表示開始日付のメニュー選択時
        case didSelectActivityStartPeriodMenu(Date)
        /// グラフ表示期間のメニュー選択時
        case didSelectActivityPeriodMenu(ActivityPeriod)
        /// グラフ表示対象のトレーニング種目選択ボタン押下時
        case tappedTargetTrainingTypeMenu
        /// グラフ表示開始日付のメニュー選択時
        case tappedDayOfCalendar(Date)
        /// アクティビティのセルタップ時
        case tappedActivityCell
        /// フィルター領域をドラッグした時
        case onDragEndedFilterArea(result: DragGestureResult)
        /// フィルター領域のトグルボタンタップ時
        case tappedFilterDisplayButton
        
        // MARK: effect event action
        
        /// 日記データを取得時
        case didReceiveDiaryData([DiaryData])
        /// 保存しているトレーニング種目取得時
        case didReceiveTrainingTypeList([TrainingTypeData])
        
        // MARK: child feature action
        
        /// カレンダーコンポーネントのイベント
        case calendar(ActivityCalendarFeature.Action)
        
        enum Alert: Equatable {
            
            /// 日記データが１件も登録されていない場合のアラート
            case emptyActivityData
        }
    }
    
    // MARK: private property
    
    @Dependency(\.dismiss) private var dismiss
    @Dependency(\.diaryListFetchApi) private var diaryListFetchApi
    @Dependency(\.trainingTypeApi) private var trainingTypeApi
    @Dependency(\.defaultAppStorage) private var defaultAppStorage
    
    // MARK: - reduce definition
    
    // swiftlint:disable:next closure_body_length
    var body: some ReducerOf<Self> {
        
        Scope(state: \.calendar, action: \.calendar) {
            
            ActivityCalendarFeature()
        }
        Reduce { state, action in
            
            logger.info("action: \(action)")
            
            switch action {
                
            case .alert:
                // TODO: 未実装
                return .none
                
            case .popup(.presented(.selectTraining(.childAction(
                    .delegate(.selectedTrainingTypeList(let selectedTrainingTypeList))
                )))):
                state.targetTrainingTypeList = selectedTrainingTypeList
                defaultAppStorage.setStringArray(selectedTrainingTypeList.map(\.id.uuidString),
                                                 .targetTrainingTypeList)
                return loadActivityResult()
                
            case .popup(.presented(.detailDayOfActivity(.childAction(
                .delegate(.tappedActivityArea(let diaryId))
            )))):
                return .none
                
            case .popup:
                return .none
                
            case .onAppear:
                state = setupStateOnAppear(state)
                return .run { send in
                    
                    await send(.didReceiveTrainingTypeList(trainingTypeApi.fetchAll()))
                }
                // TODO: 日記リストの取得、監視が残件
                
            case .didSelectActivityStartPeriodMenu(let selectDate):
                defaultAppStorage.setDouble(selectDate.timeIntervalSince1970, .activityStartPeriod)
                state.updateStartPeriodDate(selectDate)
                return loadActivityResult()
                
            case .didSelectActivityPeriodMenu(let selectPeriod):
                defaultAppStorage.setInt(selectPeriod.rawValue, .activityPeriod)
                state.updatePeriod(selectPeriod)
                return loadActivityResult()
                
            case .tappedTargetTrainingTypeMenu:
                state.popup = .selectTraining(
                    .init(childState: .init(selectingTrainingTypeList: state.targetTrainingTypeList))
                )
                return .none
                
            case .tappedDayOfCalendar:
                // TODO: 未実装
                return .none
                
            case .tappedActivityCell:
                // TODO: 未実装
                return .none
                
            case .onDragEndedFilterArea(let result):
                state.isShowingFilter = result.isUpGesture
                return .none
                
            case .tappedFilterDisplayButton:
                state.isShowingFilter.toggle()
                return .none
                
            case .didReceiveDiaryData:
                // TODO: 未実装
                return .none
                
            case .didReceiveTrainingTypeList(let trainingTypeList):
                let selectedIds = defaultAppStorage.getStringArray(.targetTrainingTypeList)
                let selectedTrainingTypeList = trainingTypeList.filter {
                    
                    selectedIds.contains($0.id.uuidString)
                }
                state.targetTrainingTypeList = selectedTrainingTypeList
                return .none
                
            case .calendar(.delegate(.selectedDay(let day))):
                
                guard let day,
                      let result = state.activityResultList.getResultOfDay(day) else {
                    
                    logger.debug("Nothing activity result in scope period.")
                    return .none
                }
                state.popup = .detailDayOfActivity(.init(childState: .init(result)))
                return .none
                
            case .calendar:
                return .none
            }
        }
        .ifLet(\.$popup, action: \.popup)
    }
}

// MARK: - popup destination definition

extension TrainingActivityGraphFeature {
    
    @Reducer(state: .equatable, action: .equatable)
    @CasePathable
    enum PopUpDestination: Equatable {
        
        case selectTraining(PopUpFeature<SelectTrainingTypeContentFeature>)
        case detailDayOfActivity(PopUpFeature<DetailDayOfActivityFeature>)
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            
            switch lhs {
                
            case .selectTraining:
                rhs.is(\.selectTraining)
                
            case .detailDayOfActivity:
                rhs.is(\.detailDayOfActivity)
            }
        }
    }
}

// MARK: - private feature method definition

private extension TrainingActivityGraphFeature {
    
    func setupStateOnAppear(_ current: State) -> State {
        
        var currentState = current
        let startPeriodDate = Date(timeIntervalSince1970: defaultAppStorage.getDouble(.activityStartPeriod))
        let activityPeriod = ActivityPeriod(rawValue: defaultAppStorage.getInt(.activityPeriod))
        currentState.updateStartPeriodDate(startPeriodDate)
        currentState.updatePeriod(activityPeriod ?? currentState.activityPeriod)
        return currentState
    }
    
    func loadActivityResult() -> Effect<Action> {
        
        return .concatenate([
            .run { send in
                
                await send(.didReceiveDiaryData(diaryListFetchApi.fetch(.now, 100))) // TODO: 仮実装
            }
        ])
    }
}
