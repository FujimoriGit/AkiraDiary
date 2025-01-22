//
//  MachoFramework
//
//  SingleSelectCalendarView.swift
//
//  Created by stotic-dev on 2025/01/13
//  Copyright © Macho All rights reserved.
//

import UIKit

final class SingleSelectCalendarView: UICalendarView, UICalendarSelectionSingleDateDelegate {
    
    private let selectHandler: (DateComponents?) -> Void
    
    init(selectHandler: @escaping (DateComponents?) -> Void) {
        
        self.selectHandler = selectHandler
        super.init(frame: .zero)
        
        selectionBehavior = UICalendarSelectionSingleDate(delegate: self)
    }
    
    // swiftlint:disable:next unused_parameter
    required init?(coder: NSCoder) {
        
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    // swiftlint:disable:next unused_parameter
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        
        selectHandler(dateComponents)
    }
}
