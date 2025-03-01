//
//  TrainingActivityGraphFeature.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/24.
//

import ComposableArchitecture
import Foundation
import MachoCore

@Reducer
struct TrainingActivityGraphFeature {    
    
    // MARK: - state definition
    
    @ObservableState
    struct State: Equatable, Sendable {
        
        // MARK: Presents States
        
        @Presents var alert: AlertState<Action.Alert>?
        
        // MARK: View State
        
        /// グラフ表示開始日付
        let activityStartPeriod: Date
        /// グラフ表示期間
        let activityPeriod: ActivityPeriod
        /// 表示トレーニングリスト
        let targetTrainingTypeList: [ConcreteTrainingTypeData]
        /// 一日毎のアクティビティ結果
        let activityResultList: ActivityResults
        
        static func getDefaultState(_ current: Date = .now) -> Self {
            
            let component = Calendar.current.dateComponents([.year, .month], from: current)
            return .init(activityStartPeriod: Calendar.current.date(from: component) ?? current,
                         activityPeriod: .month,
                         targetTrainingTypeList: [],
                         activityResultList: .init(resultList: []))
        }
    }
    
    // MARK: - action definition
    
    enum Action: Equatable, Sendable {
        
        // MARK: - rooting event action
        
        case alert(PresentationAction<Alert>)
        
        // MARK: user event action
        
        /// 画面表示時
        case onAppear
        /// グラフ表示開始日付のメニュー選択時
        case didSelectActivityStartPeriodMenu(Date)
        /// グラフ表示期間のメニュー選択時
        case didSelectActivityPeriodMenu(ActivityPeriod)
        /// グラフ表示開始日付のメニュー選択時
        case didSelectTargetTrainingTypeMenu([ConcreteTrainingTypeData])
        /// グラフ表示開始日付のメニュー選択時
        case tappedDayOfCalendar(Date)
        /// アクティビティのセルタップ時
        case tappedActivityCell
        
        // MARK: effect event action
        
        /// 日記データを取得時
        case didReceiveDiaryData([ConcreteDiaryData])
        /// 保存しているトレーニング種目取得時
        case didReceiveTrainingTypeList([ConcreteTrainingTypeData])
        
        enum Alert: Equatable {
            
            /// 日記データが１件も登録されていない場合のアラート
            case emptyActivityData
        }
    }
    
    // MARK: private property
    
    @Dependency(\.dismiss) private var dismiss
    @Dependency(\.diaryEntityClient) private var diaryListFetchApi
    @Dependency(\.trainingTypeClient) private var trainingTypeApi
    @Dependency(\.defaultAppStorage) private var defaultAppStorage
    
    // MARK: - reduce definition
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            return .none
        }
    }
}
