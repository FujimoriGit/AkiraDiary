//
//  MachoFramework
//
//  DragGestureResult.swift
//
//  Created by stotic-dev on 2024/12/16
//  Copyright © Macho All rights reserved.
//

import Foundation

struct DragGestureResult: Equatable {
    
    let startLocation: CGPoint
    let currentLocation: CGPoint
    
    var isUpGesture: Bool {
        
        return startLocation.y < currentLocation.y
    }
}
