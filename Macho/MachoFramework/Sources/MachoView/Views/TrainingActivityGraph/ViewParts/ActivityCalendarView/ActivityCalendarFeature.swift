//
//  MachoFramework
//
//  ActivityCalendarFeature.swift
//
//  Created by stotic-dev on 2025/01/05
//  Copyright © Macho All rights reserved.
//

import ComposableArchitecture
import Foundation

@Reducer
struct ActivityCalendarFeature {
    
    // MARK: - state definition
    
    @ObservableState
    struct State: Equatable, Sendable {
        
        var displayInterval: DateInterval
        var decorationDic: [DateComponents: ActivityResultDecoration]
        var initialDisplayDate: DateComponents {
            
            return Calendar.current.dateComponents(in: .current, from: displayInterval.start)
        }
    }
    
    // MARK: - action definition
    
    enum Action: Equatable {
                
        // MARK: delegate actions
        
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            
            /// カレンダーの日付を選択した時
            case selectedDay(DateComponents?)
        }
    }
    
    // MARK: - reduce definition
    
    var body: some ReducerOf<Self> {
        
        Reduce { _, action in
            
            switch action {
                
            case .delegate:
                return .none
            }
        }
    }
}
