//
//  MachoFramework
//
//  CalendarSingleSelector.swift
//
//  Created by stotic-dev on 2025/01/05
//  Copyright © Macho All rights reserved.
//

import Combine
import ComposableArchitecture
import UIKit

@MainActor
final class CalendarSingleSelector: NSObject, @preconcurrency UICalendarSelectionSingleDateDelegate, Sendable {
    
    private let selectionObserver = PassthroughSubject<DateComponents?, Never>()
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate,
                       didSelectDate dateComponents: DateComponents?) {
        
        selectionObserver.send(dateComponents)
    }
    
    func getSelector() -> UICalendarSelection {
        
        return UICalendarSelectionSingleDate(delegate: self)
    }
    
    func getObserver() -> AnyPublisher<DateComponents?, Never> {
        
        return selectionObserver.eraseToAnyPublisher()
    }
}
