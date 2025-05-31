//
//  TrainingTypeResult.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/10/19.
//

import Foundation
import MachoCore

struct TrainingTypeResult: Equatable, Identifiable {
    
    // MARK: - public property
    
    /// ID
    var id: UUID
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
    
    /// 目標のテキスト文言
    var goalResultText: String {
        
        return "目標\(String(format: resultDescriptionTextFormat, goalSet, goalNumberOfSets))"
    }
    
    /// 実績のテキスト文言
    var actualResultText: String {
        
        return "実績\(String(format: resultDescriptionTextFormat, actualSet, actualNumberOfSets))"
    }
    
    // MARK: - private property
    
    private let resultDescriptionTextFormat = ":%dセット%d回"
    
    // MARK: - initialize method
    
    init(_ content: TrainingContentData) {
        
        id = content.id
        trainingName = content.trainingType?.name ?? "-"
        goalSet = content.goalSetCount
        goalNumberOfSets = content.goalNumberOfSets
        actualSet = content.actualSetCount ?? 0
        actualNumberOfSets = content.actualNumberOfSets ?? 0
    }
}
