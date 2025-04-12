//
//  TrainingActivityGraphFeature.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/24.
//

import Combine
import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct TrainingActivityGraphFeature {
    
    // MARK: - publisher cancellable
    
    enum Cancellable: Hashable, CaseIterable {
        
        case observeTrainingType
        case observeDiaryData
    }
    
    // MARK: - state definition
    
    @ObservableState
    struct State: Equatable, Sendable {
        
        // MARK: Presents States
        
        @Presents var alert: AlertState<Action.Alert>?
        @Presents var popup: PopUpDestination.State?
        
        // MARK: Navigation State
        
        @Presents var navigationDestination: Path.State?
        
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
        var activityResultList: ActivityResults = .init()
        
        // MARK: Child Feature
        
        var calendar = ActivityCalendarFeature.State(displayInterval: .init(start: .now, end: .now),
                                                     decorationSources: [])
    }
    
    // MARK: - action definition
    
    enum Action: Equatable, Sendable {
        
        // MARK: Presents
        
        case alert(PresentationAction<Alert>)
        case popup(PresentationAction<PopUpDestination.Action>)
        
        // MARK: Navigation
        
        case navigationDestination(PresentationAction<Path.Action>)
        
        // MARK: User Event
        
        /// 画面表示時
        case onAppear
        /// 画面非表示時
        case onDisappear
        /// グラフ表示開始日付のメニュー選択時
        case didSelectActivityStartPeriodMenu(Date)
        /// グラフ表示期間のメニュー選択時
        case didSelectActivityPeriodMenu(ActivityPeriod)
        /// グラフ表示対象のトレーニング種目選択ボタン押下時
        case tappedTargetTrainingTypeMenu
        /// フィルター領域をドラッグした時
        case onDragEndedFilterArea(result: DragGestureResult)
        /// フィルター領域のトグルボタンタップ時
        case tappedFilterDisplayButton
        /// 戻るボタン押下時
        case tappedNavigationBackButton
        
        // MARK: Effect Event
        
        /// 日記データを取得時
        case didReceiveDiaryData([DiaryData])
        /// 詳細表示のための日記データの取得
        case didReceiveDiaryDataForShowingDetail(DiaryData)
        /// 保存しているトレーニング種目取得時
        case didReceiveTrainingTypeList([TrainingTypeData])
        
        // MARK: Child Feature
        
        /// カレンダーコンポーネントのイベント
        case calendar(ActivityCalendarFeature.Action)
        
        enum Alert: Equatable {
            
            /// 日記データが１件も登録されていない場合のアラート
            case emptyActivityData
        }
    }
    
    // MARK: private property
    
    @Dependency(\.dismiss) private var dismiss
    @Dependency(\.calendar) private var calendar
    @Dependency(\.diaryListFetchApi) private var diaryListFetchApi
    @Dependency(\.trainingTypeApi) private var trainingTypeApi
    @Dependency(\.defaultAppStorage) private var defaultAppStorage
    
    // MARK: - reduce definition
    
    var body: some ReducerOf<Self> {
        
        Scope(state: \.calendar, action: \.calendar) {
            
            ActivityCalendarFeature()
        }
        // swiftlint:disable:next closure_body_length
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
                let trainingTypeFilter = ActivityGraphTrainingTypeFilter(trainingTypeList: selectedTrainingTypeList)
                defaultAppStorage.setStringArray(trainingTypeFilter.selectedIdList,
                                                 .targetTrainingTypeList)
                return loadActivityResult()
                
            case .popup(.presented(.detailDayOfActivity(.childAction(
                .delegate(.tappedActivityArea(let diaryId))
            )))):
                state.popup = nil
                return fetchDiaryDataById(diaryId)
                
            case .popup:
                return .none
                
            case .navigationDestination:
                return .none
                
            case .onAppear:
                state = setupStateOnAppear(state)
                return buildEffectWhenAppear()
                
            case .onDisappear:
                return cancelObserver()
                
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
                
            case .onDragEndedFilterArea(let result):
                state.isShowingFilter = result.isUpGesture
                return .none
                
            case .tappedFilterDisplayButton:
                state.isShowingFilter.toggle()
                return .none
                
            case .tappedNavigationBackButton:
                return .merge(
                    cancelObserver(),
                    .run { _ in
                        
                        await dismiss()
                    }
                )
                
            case .didReceiveDiaryData(let diaries):
                state.updateActivityResults(diaries)
                return .none
                
            case .didReceiveDiaryDataForShowingDetail(let diary):
                state.navigationDestination = .detailScreen(.init(diary: diary))
                return cancelObserver()
                
            case .didReceiveTrainingTypeList(let trainingTypeList):
                let trainingTypeIdList = defaultAppStorage.getStringArray(.targetTrainingTypeList)
                let trainingTypeFilter = ActivityGraphTrainingTypeFilter(
                    selectedIdList: trainingTypeIdList
                )
                state.targetTrainingTypeList = trainingTypeFilter.getSelectedTrainingTypeList(trainingTypeList)
                return loadActivityResult()
                
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
        .ifLet(\.$navigationDestination, action: \.navigationDestination)
    }
}

// MARK: - popup destination definition

extension TrainingActivityGraphFeature {
    
    @Reducer(state: .equatable, action: .equatable)
    enum PopUpDestination {
        
        case selectTraining(PopUpFeature<SelectTrainingTypeContentFeature>)
        case detailDayOfActivity(PopUpFeature<DetailDayOfActivityFeature>)
    }
}

// MARK: - navigation path definition

extension TrainingActivityGraphFeature {
    
    @Reducer(state: .equatable, action: .equatable)
    enum Path {
        
        case detailScreen(DiaryDetailFeature)
    }
}

// MARK: - private feature method definition

private extension TrainingActivityGraphFeature {
    
    func setupStateOnAppear(_ current: State) -> State {
        
        var currentState = current
        guard let periodFilter = ActivityPeriodFilter(
            timestamp: defaultAppStorage.getDouble(.activityStartPeriod),
            period: defaultAppStorage.getInt(.activityPeriod)
        ) else { return current }
        currentState.updatePeriodFilter(periodFilter)
        
        return currentState
    }
    
    func buildEffectWhenAppear() -> Effect<Action> {
        
        return .concatenate([
            .run { send in
                
                await send(.didReceiveTrainingTypeList(trainingTypeApi.fetchAll()))
            },
            .publisher {
                
                diaryListFetchApi.observeDiaryList()
                    .receive(on: DispatchQueue.main)
                    .map { .didReceiveDiaryData($0) }
            }
                .cancellable(id: Cancellable.observeDiaryData),
            .publisher {
                
                trainingTypeApi.getPublisher()
                    .receive(on: DispatchQueue.main)
                    .map { .didReceiveTrainingTypeList($0) }
            }
                .cancellable(id: Cancellable.observeTrainingType)
        ])
    }
    
    func loadActivityResult() -> Effect<Action> {
        
        return .run { send in
            
            await send(.didReceiveDiaryData(diaryListFetchApi.fetch(.now, .zero)))
        }
    }
    
    func fetchDiaryDataById(_ diaryId: UUID) -> Effect<Action> {
        
        return .run { send in
            
            guard let diaryData = await diaryListFetchApi.fetch(.now, .zero)
                .first(where: { $0.id == diaryId }) else { return }
            await send(.didReceiveDiaryDataForShowingDetail(diaryData))
        }
    }
    
    func cancelObserver() -> Effect<Action> {
        
        return .merge(Cancellable.allCases.map { .cancel(id: $0) })
    }
}
