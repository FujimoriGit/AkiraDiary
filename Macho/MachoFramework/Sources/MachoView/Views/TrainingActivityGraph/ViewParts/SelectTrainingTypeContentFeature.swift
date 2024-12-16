//
//  SelectTrainingTypeContentFeature.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/12/11.
//

import ComposableArchitecture
import Foundation

@Reducer
struct SelectTrainingTypeContentFeature: PopUpableContentFeature {
    
    // MARK: - cancellable definition
    
    struct Cancellable: Hashable {}
    
    // MARK: - state definition
    
    @ObservableState
    struct State: Equatable {
        
        /// 選択中のトレーニング種目
        var selectingTrainingTypeList: [TrainingTypeData]
        /// 全てのトレーニング種目
        var selectableTrainingTypeList: [TrainingTypeData] = []
        
        init(selectingTrainingTypeList: [TrainingTypeData]) {
            
            self.selectingTrainingTypeList = selectingTrainingTypeList
        }
    }
    
    // MARK: - action definition
    
    enum Action: PopUpableContentAction {
        
        // MARK: event action
        
        /// 画面表示時
        case onAppear
        /// 画面非表示前
        case willDismiss
        /// トレーニング種目のコンテンツ押下時
        case tappedTrainingTypeContent(TrainingTypeData)
        /// 閉じるボタン押下時
        case tappedCloseButton
        
        // MARK: effect action
        
        /// 選択可能なトレーニング種目取得時
        case didLoadSelectableTrainingTypeList([TrainingTypeData])
        
        // MARK: delegate action
        
        /// デリゲートアクション
        case delegate(Delegate)
        
        static let willDismissAction: Self = .willDismiss
    }
    
    // MARK: - dependency
    
    @Dependency(\.trainingTypeApi) private var trainingTypeApi
    
    // MARK: - reducer body
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            
            logger.info("action: \(action), state: \(state)")
            print("\(#file) \(#function) action: \(action)")
            
            switch action {
                
            case .onAppear:
                return .concatenate([
                    .run { send in
                        
                        let selectableTrainingTypeList = await trainingTypeApi.fetchAllType()
                        await send(.didLoadSelectableTrainingTypeList(selectableTrainingTypeList))
                    },
                    .publisher {
                        
                        return trainingTypeApi.getObserver()
                            .receive(on: DispatchQueue.main)
                            .map { .didLoadSelectableTrainingTypeList($0) }
                    }
                        .cancellable(id: Cancellable())
                ])
                
            case .willDismiss:
                return .concatenate(
                    .run { [selectingTrainingTypeList = state.selectingTrainingTypeList] send in
                        
                        print("selectedTrainingTypeList with onDisappear.")
                        await send(.delegate(.selectedTrainingTypeList(selectingTrainingTypeList)))
                    },
                    .cancel(id: Cancellable())
                )
                
            case .tappedTrainingTypeContent(let target):
                if let targetIndex = state.selectingTrainingTypeList.firstIndex(of: target) {
                    
                    state.selectingTrainingTypeList.remove(at: targetIndex)
                }
                else {
                    
                    state.selectingTrainingTypeList.append(target)
                }
                return .none
                
            case .tappedCloseButton:
                return .run { send in
                    await send(.willDismiss, animation: .easeInOut)
                }
                
            case .didLoadSelectableTrainingTypeList(let trainingTypeList):
                state.selectableTrainingTypeList = trainingTypeList
                state.selectingTrainingTypeList = state.selectingTrainingTypeList.compactMap { type in
                    
                    guard let targetType = trainingTypeList.first(where: { $0 == type }) else {
                        
                        return nil
                    }
                    return targetType
                }
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}

extension SelectTrainingTypeContentFeature.Action {
    
    enum Delegate: Equatable {
        
        /// 選択トレーニング種目の決定
        case selectedTrainingTypeList([TrainingTypeData])
    }
}
