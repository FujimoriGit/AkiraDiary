//
//  MachoFramework
//
//  DiaryList.swift
//
//  Created by stotic-dev on 2025/02/02
//  Copyright © Macho All rights reserved.
//

import Foundation

struct DiaryList: Equatable {
    
    var elements: [DiaryListItemFeature.State]
    var hasElements: Bool {
        
        return !elements.isEmpty
    }
    
    func getFilteredList(filters: [DiaryListFilterItem]) -> [DiaryListItemFeature.State] {

        if filters.isEmpty { return elements }
        return elements.filter { item in
            
            return filters.contains {
                
                return $0.isMatchFilter(isAchieved: item.isWin,
                                        trainingList: item.trainingList,
                                        tagList: item.tagList)
            }
        }
    }
    
    func getTargetDiaryById(_ id: UUID) -> DiaryListItemFeature.State? {
        
        return elements.first { $0.id == id }
    }
    
    func getLoadStartDate() -> Date? {
        
        return elements.last?.date
    }
    
    mutating func addLoadedDiaries(_ diaries: [DiaryData]) {
        
        let addingDiaryItemList = diaries.map { DiaryListItemFeature.State($0) }
        var sortElements = addingDiaryItemList.reduce(into: elements) { current, new in
            
            if let targetIndex = current.firstIndex(where: { $0.id == new.id }) {
                
                current[targetIndex] = new
            }
            else {
                
                current.append(new)
            }
        }
        sortElements.sort { $0.date > $1.date }
        
        self.elements = sortElements
    }
    
    mutating func deleteDiaryById(_ id: UUID) {
        
        guard let targetIndex = elements.firstIndex(where: { $0.id == id }) else {
            
            assertionFailure("Nothing remove target id.")
            return
        }
        
        elements.remove(at: targetIndex)
    }
}
