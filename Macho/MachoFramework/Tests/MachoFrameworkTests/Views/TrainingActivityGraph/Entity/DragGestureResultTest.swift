//
//  MachoFramework
//
//  DragGestureResultTest.swift
//
//  Created by stotic-dev on 2025/01/30
//  Copyright © Macho All rights reserved.
//

import Foundation
import Testing
@testable import MachoView

struct DragGestureResultTest {

    @Test(
        arguments: [
            (CGPoint(x: 100, y: 0), CGPoint(x: 90, y: -1)),
            (CGPoint(x: 10, y: Int.max), CGPoint(x: 100, y: Int.min)),
            (CGPoint(x: 10, y: 10000), CGPoint(x: 100, y: 9999)),
            (CGPoint(x: 10, y: -10000), CGPoint(x: 100, y: -10001))
        ]
    )
    func 開始位置の高さが現在位置より高いと下スワイプしたと判断する(
        startLocation: CGPoint,
        currentLocation: CGPoint
    ) async throws {
        
        let sut = DragGestureResult(startLocation: startLocation,
                                    currentLocation: currentLocation)
        
        #expect(!sut.isUpGesture)
    }
    
    @Test(
        arguments: [
            (CGPoint(x: 100, y: -1), CGPoint(x: 90, y: 0)),
            (CGPoint(x: 10, y: Int.min), CGPoint(x: 100, y: Int.max)),
            (CGPoint(x: 10, y: 9999), CGPoint(x: 100, y: 10000)),
            (CGPoint(x: 10, y: -10001), CGPoint(x: 100, y: -10000))
        ]
    )
    func 開始位置の高さが現在位置より低いと上スワイプしたと判断する(
        startLocation: CGPoint,
        currentLocation: CGPoint
    ) async throws {
        
        let sut = DragGestureResult(startLocation: startLocation,
                                    currentLocation: currentLocation)
        
        #expect(sut.isUpGesture)
    }
}
