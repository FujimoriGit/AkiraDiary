//
//  AddTrainingTypeFeature.swift
//  MachoFramework
//  
//  Created by Daiki Fujimori on 2024/11/30
//  

import ComposableArchitecture

@Reducer
struct AddTrainingTypeFeature {
    
    // MARK: - State
    
    @ObservableState
    struct State: Equatable {
        
        var name = ""
        var isEnableSaveButton = false
    }
    
    // MARK: - Action
    
    enum Action: Sendable, Equatable {
        
        case cancelButtonTapped
        case setName(String)
        case saveButtonTapped
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            
            case addedTrainingType(String)
        }
    }
    
    // MARK: - Dependencies
    
    @Dependency(\.trainingTypeApi) var trainingTypeApi
    @Dependency(\.dismiss) var dismiss
    
    // MARK: - body
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            
            switch action {
                
            case .cancelButtonTapped:
                return .run { _ in await dismiss() }
                
            case .setName(let name):
                state.name = name
                state.isEnableSaveButton = !state.name.isEmpty
                return .none
                
            case .saveButtonTapped:
                return .run { [name = state.name] send in
                    
                    if await saveTrainingType(trainingTypeName: name) {
                        
                        await send(.delegate(.addedTrainingType(name)))
                    }
                    await dismiss()
                }
                
            case .delegate:
                return .none
            }
        }
    }
}

private extension AddTrainingTypeFeature {
    
    func saveTrainingType(trainingTypeName: String) async -> Bool {
        
        return await trainingTypeApi.add(trainingTypeName)
    }
}
