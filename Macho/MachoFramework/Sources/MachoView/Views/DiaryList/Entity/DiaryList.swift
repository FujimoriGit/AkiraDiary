//
//  MachoFramework
//
//  DiaryList.swift
//
//  Created by stotic-dev on 2025/02/02
//  Copyright © Macho All rights reserved.
//

import Foundation

struct DiaryList {
    
    let elements: [DiaryListItemFeature.State]
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
    
    func hasDisplayElements(_ displayElements: [DiaryListItemFeature.State]) -> Bool {
        
        return !displayElements.isEmpty
    }
}

extension DiaryList {
    
    init(adding elements: [DiaryData], current: [DiaryListItemFeature.State]) {
        
        let addingDiaryItemList = elements.map { DiaryListItemFeature.State($0) }
        var sortElements = addingDiaryItemList.reduce(into: current) { current, new in
            
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
    
    init(removing id: UUID, current: [DiaryListItemFeature.State]) {
        
        var removedList = current
        guard let targetIndex = removedList.firstIndex(where: { $0.id == id }) else {
            
            assertionFailure("Nothing remove target id.")
            self.elements = current
            return
        }
        
        removedList.remove(at: targetIndex)
        self.elements = removedList
    }
}
