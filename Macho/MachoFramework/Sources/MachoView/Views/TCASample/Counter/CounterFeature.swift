//
//  CounterFeature.swift
//  Macho
//  
//  Created by Daiki Fujimori on 2023/10/28
//  
//

import ComposableArchitecture
import Foundation

struct CounterFeature: Reducer {
    
    // MARK: State
    
    struct State: Equatable {
        
        var count = 0
        var fact: String?
        var isLoading = false
        var isTimerRunning = false
    }
    
    // MARK: - Action
    
    enum Action: Equatable {
        
        /// インクリメントボタンタップ時
        case incrementButtonTapped
        /// デクリメントボタンタップ時
        case decrementButtonTapped
        /// factボタン押下時
        case factButtonTapped
        /// factレスポンス返却時
        case factResponse(String)
        
        case timerTick
        case toggleTimerButtonTapped
    }
    
    // MARK: - body
    
    enum CancelID { case timer }
    
    
    @Dependency(\.continuousClock) var clock
    @Dependency(\.numberFact) var numberFact


    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            
            switch action {
                
            case .incrementButtonTapped:
                // [同期処理] 受信したActionによってStateの更新を行う.
                state.count += 1
                state.fact = nil
                return .none
                
            case .decrementButtonTapped:
                // [同期処理] 受信したActionによってStateの更新を行う.
                state.count -= 1
                state.fact = nil
                return .none
                
            case .factButtonTapped:
                state.fact = nil
                state.isLoading = true
                return .run { [count = state.count] send in
                    
                    try await send(.factResponse(numberFact.fetch(count)))
                }
                
            case let .factResponse(fact):
                state.fact = fact
                state.isLoading = false
                return .none
                
            case .timerTick:
                state.count += 1
                state.fact = nil
                return .none
                
            case .toggleTimerButtonTapped:
                state.isTimerRunning.toggle()
                if state.isTimerRunning {
                    
                    return .run { send in
                        
                        for await _ in self.clock.timer(interval: .seconds(1)) {
                            
                            await send(.timerTick)
                        }
                    }
                    .cancellable(id: CancelID.timer)
                } else {
                    
                    return .cancel(id: CancelID.timer)
                }
            }
        }
    }
}
