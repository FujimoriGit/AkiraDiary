//
//  ActivityResults.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/24.
//

import Foundation

struct ActivityResults: Equatable {
    
    private let resultList: [ActivityResultOfDay]
    
    init(resultList: [ActivityResultOfDay]) {
        
        self.resultList = resultList
    }
    
    /// カレンダーの各日のコンポーネントにデコレーションするクラスを生成する
    func buildCalendarDecorator() -> [DateComponents: ActivityResultDecoration] {
        
        return resultList.reduce(into: [:]) {
            
            $0.updateValue($1.calendarDecoration,
                           forKey: Calendar.current.dateComponents([.year, .month, .day], from: $1.targetDate))
        }
    }
}

extension ActivityResults: RandomAccessCollection {
    
    typealias Element = ActivityResultOfDay
    typealias Index = Int
    
    var startIndex: Int { resultList.startIndex }
    
    var endIndex: Int { resultList.endIndex }
    
    subscript(position: Int) -> ActivityResultOfDay {
        
        return resultList[position]
    }
    
    // swiftlint:disable:next identifier_name
    func index(after i: Int) -> Int {
        
        return resultList.index(after: i)
    }
}
