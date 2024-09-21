//
//  AddTagFeature.swift
//
//  
//  Created by Daiki Fujimori on 2024/04/06
//  
//

import ComposableArchitecture

struct AddTagFeature: Reducer {
    
    struct State: Equatable {
        
        var tag: Tag
        var isEnableSaveButton = false
    }
    
    enum Action: Equatable {
        
        case cancelButtonTapped
        case delegate(Delegate)
        case saveButtonTapped
        case setTagName(String)
        
        enum Delegate: Equatable {
            
            case saveTag(Tag)
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
            return .run { [tag = state.tag] send in
                
                await send(.delegate(.saveTag(tag)))
                await dismiss()
            }
            
        case .setTagName(let tagName):
            state.tag.tagName = tagName
            state.isEnableSaveButton = !tagName.isEmpty
            return .none
        }
    }
}
