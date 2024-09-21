//
//  AddGoalFeature.swift
//
//  
//  Created by Daiki Fujimori on 2024/05/03
//  
//

import ComposableArchitecture

struct AddGoalFeature: Reducer {
    
    struct State: Equatable {
        
        var goal: Goal
        var isEnableSaveButton = false
    }
    
    enum Action: Equatable {
        
        case cancelButtonTapped
        case delegate(Delegate)
        case saveButtonTapped
        case setGoalName(String)
        case setNumberOfSets(Int)
        case setCount(Int)
        
        enum Delegate: Equatable {
            
            case saveTag(Goal)
        }
    }
    
    @Dependency(\.dismiss) var dismiss
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        
        switch action {
            
        case .cancelButtonTapped:
            return .run { _ in await dismiss() }
            
        case .delegate:
            return .none
            
        case .saveButtonTapped:
            return .run { [tag = state.goal] send in
                
                await send(.delegate(.saveTag(tag)))
                await dismiss()
            }
            
        case .setGoalName(let goalName):
            state.goal.goalName = goalName
            state.isEnableSaveButton = !goalName.isEmpty && state.goal.setCount > 0 && state.goal.numberOfSets > 0
            return .none
            
        case .setNumberOfSets(let numberOfSets):
            state.goal.numberOfSets = numberOfSets
            state.isEnableSaveButton = numberOfSets > 0 && !state.goal.goalName.isEmpty && state.goal.setCount > 0
            return .none
            
        case .setCount(let setCount):
            state.goal.setCount = setCount
            state.isEnableSaveButton = setCount > 0 && !state.goal.goalName.isEmpty && state.goal.numberOfSets > 0
            return .none
        }
    }
}
