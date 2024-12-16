//
//  PopUpFeature.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/12/11.
//

import ComposableArchitecture
import Foundation

@Reducer
struct PopUpFeature<ChildContentFeature: PopUpableContentFeature> where ChildContentFeature.State: Equatable & Sendable, ChildContentFeature.Action: PopUpableContentAction {
    
    struct DebounceId: Hashable {}
    
    // MARK: - state definition
    
    @ObservableState
    struct State: Equatable, Sendable {
        
        var isShowing = false
        var childState: ChildContentFeature.State
    }
    
    // MARK: - action definition
    
    enum Action: Equatable, Sendable {
        
        // MARK: event action
        
        case onAppear
        case tappedBackground
        
        // MARK: child content action
        
        case childAction(ChildContentFeature.Action)
    }
    
    // MARK: - dependency
    
    @Dependency(\.dismiss) private var dismiss
    
    // MARK: - reducer definition
    
    var body: some ReducerOf<Self> {
        
        Scope(state: \.childState, action: \.childAction) {
            ChildContentFeature()
        }
        Reduce { state, action in
            
            logger.info("action: \(action)")
            
            switch action {
                
            case .onAppear:
                state.isShowing = true
                return .none
                
            case .tappedBackground:
                return .run { send in
                    
                    await send(.childAction(.willDismissAction),
                               animation: .easeInOut)
                }
                
            case .childAction(.willDismissAction):
                state.isShowing = false
                return dismissPopUp()
                
            case .childAction:
                return .none
            }
        }
    }
}

private extension PopUpFeature {
    
    func dismissPopUp() -> Effect<Action> {
        
        return .run { _ in
            
            await dismiss()
        }
        .debounce(id: DebounceId(),
                  for: .seconds(1.0),
                  scheduler: DispatchQueue.main)
    }
}
