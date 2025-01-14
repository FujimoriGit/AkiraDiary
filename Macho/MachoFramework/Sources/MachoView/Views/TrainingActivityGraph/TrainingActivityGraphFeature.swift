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
        @Presents var selectTrainingPopUp: PopUpFeature<SelectTrainingTypeContentFeature>.State?
        
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
        var activityResultList: ActivityResults = .init(resultList: [])
        
        // MARK: child feature state
        
        var calendar = ActivityCalendarFeature.State(displayInterval: .init(start: .now, end: .now),
                                                     calendarDecorator: .getInitial())
    }
    
    // MARK: - action definition
    
    enum Action: Equatable, Sendable {
        
        // MARK: - rooting event action
        
        case alert(PresentationAction<Alert>)
        case selectTrainingPopUp(PresentationAction<PopUpFeature<SelectTrainingTypeContentFeature>.Action>)
        
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
                
            case .selectTrainingPopUp(.presented(
                .childAction(
                    .delegate(.selectedTrainingTypeList(let selectedTrainingTypeList))
                )
            )):
                state.targetTrainingTypeList = selectedTrainingTypeList
                defaultAppStorage.setStringArray(selectedTrainingTypeList.map(\.id.uuidString),
                                                 .targetTrainingTypeList)
                return loadActivityResult()
                
            case .selectTrainingPopUp:
                return .none
                
            case .onAppear:
                state = setupStateOnAppear(state)
                return .run { send in
                    
                    await send(.didReceiveTrainingTypeList(trainingTypeApi.fetchAll()))
                }
                // TODO: 日記リストの取得、監視が残件
                
            case .didSelectActivityStartPeriodMenu(let selectDate):
                defaultAppStorage.setDouble(selectDate.timeIntervalSince1970, .activityStartPeriod)
                state.activityStartPeriod = selectDate
                return loadActivityResult()
                
            case .didSelectActivityPeriodMenu(let selectPeriod):
                defaultAppStorage.setInt(selectPeriod.rawValue, .activityPeriod)
                state.activityPeriod = selectPeriod
                return loadActivityResult()
                
            case .tappedTargetTrainingTypeMenu:
                state.selectTrainingPopUp = .init(
                    childState: .init(selectingTrainingTypeList: state.targetTrainingTypeList)
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
                
            case .calendar:
                return .none
            }
        }
        .ifLet(\.$selectTrainingPopUp, action: \.selectTrainingPopUp) {
            PopUpFeature<SelectTrainingTypeContentFeature>()
        }
    }
}

// MARK: - private feature method definition

private extension TrainingActivityGraphFeature {
    
    func setupStateOnAppear(_ current: State) -> State {
        
        var currentState = current
        let startPeriodDate = Date(timeIntervalSince1970: defaultAppStorage.getDouble(.activityStartPeriod))
        let activityPeriod = ActivityPeriod(rawValue: defaultAppStorage.getInt(.activityPeriod))
        currentState.activityStartPeriod = startPeriodDate
        currentState.activityPeriod = activityPeriod ?? currentState.activityPeriod
        return currentState
    }
    
    func loadActivityResult() -> Effect<Action> {
        
        return .none
    }
}
