//
//  ActivityResults.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/24.
//

import Foundation

struct ActivityResults: Equatable {
    
    private let resultList: [ActivityResultOfDay]
    
    init(_ diaries: [DiaryData]) {
        
        resultList = diaries.reduce(into: [[DiaryData]]()) { partialResult, diary in
            
            let targetDateComponent = Calendar.current.dateComponents([.year, .month, .day], from: diary.date)
            let targetIndex = partialResult.firstIndex {
                
                guard let diaryDate = $0.first?.date else { return false }
                return Calendar.current.date(diaryDate, matchesComponents: targetDateComponent)
            }
            
            guard let targetIndex else {
                
                partialResult.append([diary])
                return
            }
            partialResult[targetIndex].append(diary)
        }
        .map { ActivityResultOfDay(dayOfdiaries: $0) }
    }
    
    /// カレンダーの各日のコンポーネントにデコレーションするクラスを生成する
    func buildCalendarDecorator() -> [DateComponents: ActivityResultDecoration] {
        
        return resultList.reduce(into: [:]) {
            
            $0.updateValue($1.calendarDecoration,
                           forKey: Calendar.current.dateComponents([.year, .month, .day],
                                                                   from: $1.targetDate))
        }
    }
    
    /// 引数の日にちに合致するアクティビティ結果を取得する
    func getResultOfDay(_ day: DateComponents, calendar: Calendar) -> ActivityResultOfDay? {
        
        return resultList.first {
            
            return calendar.dateComponents([.year, .month, .day], from: $0.targetDate).isMatchDate(day)
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
