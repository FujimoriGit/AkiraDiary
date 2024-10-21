//
//  TrainingTypeResult.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/10/19.
//

import Foundation
import RealmHelper

struct TrainingTypeResult {
    
    /// 種目名
    let trainingName: String
    /// 目標セット数
    let goalSet: Int
    /// 目標回数/セット
    let goalNumberOfSets: Int
    /// 実際のセット数
    let actualSet: Int
    /// 実際の回数/セット
    let actualNumberOfSets: Int
    
    /// 目標達成したかどうか
    var isAchieved: Bool {
        
        if actualSet > goalSet ||
            (actualSet == goalSet && actualNumberOfSets >= goalNumberOfSets) { return true }
        return false
    }
    
    init(goal: TrainingGoalEntity) {
        
        trainingName = goal.goalType.name
        goalSet = goal.setCount
        goalNumberOfSets = goal.numberOfSets
        actualSet = goal.setCount
        actualNumberOfSets = goal.numberOfSets
    }
}
