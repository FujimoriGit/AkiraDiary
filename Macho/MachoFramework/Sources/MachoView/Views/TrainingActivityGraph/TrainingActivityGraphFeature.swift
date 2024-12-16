//
//  TrainingActivityGraphFeature.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/24.
//

import ComposableArchitecture
import Foundation

@Reducer
struct TrainingActivityGraphFeature {    
    
    // MARK: - state definition
    
    @ObservableState
    struct State: Equatable, Sendable {
        
        // MARK: Presents States
        
        @Presents var alert: AlertState<Action.Alert>?
        @Presents var destination: Destination.State?
        
        // MARK: View State
        
        var viewState: ViewState
        var currentActivityPeriodTitle: String {
            
            return viewState.activityPeriod.title
        }
        
        init() {
            
            viewState = .init()
        }
        
        struct ViewState: Equatable {
            
            /// グラフ表示開始日付
            var activityStartPeriod: Date
            /// グラフ表示期間
            var activityPeriod: ActivityPeriod
            /// 表示トレーニングリスト
            var targetTrainingTypeList: SelectTrainingTypeContentFeature.State
            /// 一日毎のアクティビティ結果
            var activityResultList: ActivityResults
            
            init(activityStartPeriod: Date,
                 activityPeriod: ActivityPeriod,
                 targetTrainingTypeList: [TrainingTypeData],
                 activityResultList: ActivityResults) {
                
                self.activityStartPeriod = activityStartPeriod
                self.activityPeriod = activityPeriod
                self.targetTrainingTypeList = .init(selectingTrainingTypeList: targetTrainingTypeList)
                self.activityResultList = activityResultList
            }
            
            init(current: Date = Date.now) {
                
                let component = Calendar.current.dateComponents([.year, .month], from: current)
                self.activityStartPeriod = Calendar.current.date(from: component) ?? current
                self.activityPeriod = .month
                self.targetTrainingTypeList = .init(selectingTrainingTypeList: [])
                self.activityResultList = .init(resultList: [])
            }
        }
    }
    
    // MARK: - action definition
    
    enum Action: Equatable, Sendable {
        
        // MARK: - rooting event action
        
        case alert(PresentationAction<Alert>)
        case destination(PresentationAction<Destination.Action>)
        
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
        
        // MARK: effect event action
        
        /// 日記データを取得時
        case didReceiveDiaryData([DiaryData])
        /// 保存しているトレーニング種目取得時
        case didReceiveTrainingTypeList([TrainingTypeData])
        
        @CasePathable
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
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            
            logger.info("action: \(action)")
            
            switch action {
                
            case .alert(_):
                // TODO: 未実装
                return .none
                
            case .destination(.presented(.selectTrainingTypePopUp(.childAction(.delegate(.selectedTrainingTypeList(let selectedTrainingTypeList)))))):
                // TODO: 未実装
                return .none
                
            case .destination(_):
                // TODO: 未実装
                return .none
                
            case .onAppear:
                // TODO: 未実装
                return .none
                
            case .didSelectActivityStartPeriodMenu(let selectDate):
                defaultAppStorage.setDouble(selectDate.timeIntervalSince1970, .activityStartPeriod)
                state.updateActivityStartPeriod(selectDate)
                return loadActivityResult()
                
            case .didSelectActivityPeriodMenu(let selectPeriod):
                defaultAppStorage.setInt(selectPeriod.rawValue, .activityPeriod)
                state.updateActivityPeriod(selectPeriod)
                return loadActivityResult()
                
            case .tappedTargetTrainingTypeMenu:
                state.destination = .selectTrainingTypePopUp(.init(childState: state.viewState.targetTrainingTypeList))
                return .none
                
            case .tappedDayOfCalendar(_):
                // TODO: 未実装
                return .none
                
            case .tappedActivityCell:
                // TODO: 未実装
                return .none
                
            case .didReceiveDiaryData(_):
                // TODO: 未実装
                return .none
                
            case .didReceiveTrainingTypeList(_):
                // TODO: 未実装
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension TrainingActivityGraphFeature {
    
    @Reducer(state: .equatable, .sendable, action: .equatable, .sendable)
    enum Destination: Equatable {
        
        case selectTrainingTypePopUp(PopUpFeature<SelectTrainingTypeContentFeature>)
        
        var id: Int {
            
            switch self {
                
            case .selectTrainingTypePopUp:
                return 0
            }
        }
        
        static func == (lhs: TrainingActivityGraphFeature.Destination, rhs: TrainingActivityGraphFeature.Destination) -> Bool {
            
            return lhs.id == rhs.id
        }
    }
}

// MARK: - private feature method definition

private extension TrainingActivityGraphFeature {
    
    func loadActivityResult() -> Effect<Action> {
        
        return .none
    }
}

// MARK: - state util method definition

private extension TrainingActivityGraphFeature.State {
    
    mutating func updateActivityStartPeriod(_ selectedDate: Date) {
        
        viewState.activityStartPeriod = selectedDate
    }
    
    mutating func updateActivityPeriod(_ selectedPeriod: ActivityPeriod) {
        
        viewState.activityPeriod = selectedPeriod
    }
}
