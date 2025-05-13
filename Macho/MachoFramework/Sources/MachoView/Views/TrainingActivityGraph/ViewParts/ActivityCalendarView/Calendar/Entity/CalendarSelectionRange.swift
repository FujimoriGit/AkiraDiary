//
//  MachoFramework
//
//  CalendarSelectionRange.swift
//
//  Created by stotic-dev on 2025/01/25
//  Copyright © Macho All rights reserved.
//

import Foundation

struct CalendarSelectionRange {
    
    let visibleComponents: DateComponents
    let availableDateRange: DateInterval
    let calendar: Calendar
    
    func makeSelectionRangeUpdateEvents(_ newAvailableDateRange: DateInterval,
                                        _ newVisibleComponents: DateComponents) -> [UpdateEvent] {
        
        var events: [UpdateEvent] = []
        
        // 変更後の表示可能期間が現在の表示日から外れていない場合、
        // そのまま表示可能期間を設定してもクラッシュしないため、受けた表示可能期間で更新する
        guard let visibleDate = calendar.date(from: visibleComponents),
              !newAvailableDateRange.contains(visibleDate) else {
            
            events.append(.availableDateRange(newAvailableDateRange))
            return createAddingVisibleDateUpdateAnimationEvents(
                currentEvents: events,
                newVisibleComponents: newVisibleComponents,
                updatedAvailableDateRange: newAvailableDateRange
            )
        }
        
        let tempVisibleDate = visibleDate < newAvailableDateRange.start ?
        newAvailableDateRange.start :
        newAvailableDateRange.end
        
        // 変更後の表示日が現在の表示可能期間外の場合、そのまま表示日を設定するとクラッシュするため、
        // 現在の表示可能期間を変更前の表示期間〜変更後の表示期間となるようにする
        if !availableDateRange.contains(tempVisibleDate) {
            
            let start = min(visibleDate, tempVisibleDate)
            let end = max(visibleDate, tempVisibleDate)
            let tempAvailableDateRange = DateInterval(start: start, end: end)
            
            events.append(.availableDateRange(tempAvailableDateRange))
        }
        
        // 変更後の表示可能期間が現在の表示日から外れている場合、そのまま表示可能期間を設定するとクラッシュするため
        // 現在の表示日を変更後の表示可能期間内に収まるように更新してから、表示可能期間を更新する
        events.append(.visibleDateComponents(
            calendar.dateComponents([.year, .month], from: tempVisibleDate)
        ))
        events.append(.availableDateRange(newAvailableDateRange))
        
        // 受け取った値で表示日をアニメーションで更新
        return createAddingVisibleDateUpdateAnimationEvents(
            currentEvents: events,
            newVisibleComponents: newVisibleComponents,
            updatedAvailableDateRange: newAvailableDateRange
        )
    }
    
    enum UpdateEvent: Equatable {
        
        /// 表示日を更新
        case visibleDateComponents(DateComponents)
        /// 表示日をアニメーションを伴って更新
        case visibleDateComponentsWithAnimation(DateComponents)
        /// 表示可能期間を更新
        case availableDateRange(DateInterval)
    }
}

private extension CalendarSelectionRange {
    
    func canUpdateAvailableDateRange(_ newAvailableDateRange: DateInterval,
                                     _ currentVisibleComponentsDate: DateComponents) -> Bool {
        
        guard let visibleDate = calendar.date(from: currentVisibleComponentsDate) else {
            
            return true
        }
        return newAvailableDateRange.contains(visibleDate)
    }
    
    func createAddingVisibleDateUpdateAnimationEvents(
        currentEvents: [UpdateEvent],
        newVisibleComponents: DateComponents,
        updatedAvailableDateRange: DateInterval
    ) -> [UpdateEvent] {
        
        var resultEvents = currentEvents
        if let selectVisibleDate = calendar.date(from: newVisibleComponents),
           updatedAvailableDateRange.contains(selectVisibleDate) {
            
            resultEvents.append(.visibleDateComponentsWithAnimation(newVisibleComponents))
        }
        
        return resultEvents
    }
}
