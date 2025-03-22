//
//  MachoFramework
//
//  ActivityGraphTrainingTypeFilter.swift
//
//  Created by stotic-dev on 2025/01/23
//  Copyright © Macho All rights reserved.
//

struct ActivityGraphTrainingTypeFilter {
    
    let selectedIdList: [String]
    
    init(selectedIdList: [String]) {
        
        self.selectedIdList = selectedIdList
    }
    
    init(trainingTypeList: [TrainingTypeData]) {
        
        selectedIdList = trainingTypeList.map(\.id.uuidString)
    }
    
    func getSelectedTrainingTypeList(_ trainingTypeList: [TrainingTypeData]) -> [TrainingTypeData] {
        
        return trainingTypeList.filter {
            
            return selectedIdList.contains($0.id.uuidString)
        }
    }
    
    func isMatch(_ diary: Diary) -> Bool {
        
        // 選択中のトレーニング種目のフィルターがなければ、全てマッチとして扱う
        if selectedIdList.isEmpty { return true }
        
        return selectedIdList.contains {
            
            return diary.goals.map(\.trainingType.id.uuidString).contains($0)
        }
    }
}
