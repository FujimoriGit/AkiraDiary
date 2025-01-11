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
        
        var calendarView = CalendarFeature.State()
        var displayInterval: DateInterval
        var calendarDecorator: CalendarViewDecolator? = nil
        var initialDisplayDate: DateComponents {
            
            return Calendar.current.dateComponents(in: .current, from: displayInterval.start)
        }
    }
    
    // MARK: - action definition
    
    enum Action: Equatable {
        
        // MARK: event actions
        
        /// 画面表示時
        case onAppear
        
        // MARK: delegate actions
        
        /// カレンダー画面のAction
        case calendarView(CalendarFeature.Action)
    }
    
    // MARK: - reduce definition
    
    var body: some ReducerOf<Self> {
        
        Scope(state: \.calendarView, action: \.calendarView) {
            CalendarFeature()
        }
        Reduce { state, action in
            
            switch action {
                
            case .onAppear:
                state.calendarDecorator = CalendarViewDecolator(componentsDecorationDic: [:])
                return .none
                
            case .calendarView(.didSelectDay(let day)):
                print("did select calendar day: \(day?.description)")
                return .none
                
            case .calendarView:
                return .none
            }
        }
    }
}

private extension ActivityCalendarFeature {
    
}
