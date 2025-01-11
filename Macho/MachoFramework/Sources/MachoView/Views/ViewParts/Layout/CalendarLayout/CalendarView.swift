//
//  MachoFramework
//
//  CalendarView.swift
//
//  Created by stotic-dev on 2025/01/05
//  Copyright © Macho All rights reserved.
//

import ComposableArchitecture
import UIKit
import SwiftUI

struct CalendarView: UIViewRepresentable {
    
    @Bindable private var store: StoreOf<CalendarFeature>
    @Environment(\.locale) private var locale
    
    private let initialDate: DateComponents
    private let interval: DateInterval
    private let decolator: UICalendarViewDelegate?
    
    init(store: StoreOf<CalendarFeature>,
         initialDate: DateComponents,
         interval: DateInterval,
         decolator: UICalendarViewDelegate? = nil) {
        
        self.store = store
        self.initialDate = initialDate
        self.interval = interval
        self.decolator = decolator
    }
    
    func makeUIView(context: Context) -> CalendarUIView {
        
        let content = CalendarUIView { selectedDate in
            
            store.send(.didSelectDay(selectedDate))
        }
        
        return content
    }

    func updateUIView(_ uiView: CalendarUIView, context: Context) {
        
        uiView.visibleDateComponents = initialDate
        uiView.availableDateRange = interval
        uiView.locale = locale
        uiView.delegate = decolator
    }
}

final class CalendarUIView: UICalendarView, UICalendarSelectionSingleDateDelegate {
    
    private let selectHandler: (DateComponents?) -> Void
    
    init(selectHandler: @escaping (DateComponents?) -> Void) {
        
        self.selectHandler = selectHandler
        super.init(frame: .zero)
        
        selectionBehavior = UICalendarSelectionSingleDate(delegate: self)
    }
    
    required init?(coder: NSCoder) {
        
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        
        selectHandler(dateComponents)
    }
}

@Reducer
struct CalendarFeature {
    
    @ObservableState
    struct State: Equatable {}
    
    enum Action: Equatable {
        
        case didSelectDay(DateComponents?)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            
            switch action {
                
            case .didSelectDay:
                return .none
            }
        }
    }
}
