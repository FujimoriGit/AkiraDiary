//
//  MachoFramework
//
//  CalendarViewDecoratable.swift
//
//  Created by stotic-dev on 2025/01/13
//  Copyright © Macho All rights reserved.
//

import UIKit

protocol CalendarViewDecoratable: Equatable, Sendable {
    
    func getDecoration() -> UICalendarView.Decoration
}
