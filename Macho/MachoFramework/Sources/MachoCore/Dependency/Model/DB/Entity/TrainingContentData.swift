//
//  TrainingContentData.swift
//
//
//  Created by Daiki Fujimori on 2024/04/13
//

import Foundation

public protocol TrainingContentData: Equatable, Sendable, Identifiable {
    
    associatedtype TrainingType: TrainingTypeData
    
    var id: UUID { get }
    /// 種目
    var trainingType: TrainingType? { get }
    /// 目標1セットの回数
    var goalNumberOfSets: Int { get }
    /// 目標セット数
    var goalSetCount: Int { get }
    /// 達成した1セットの回数
    var actualNumberOfSets: Int? { get }
    /// 達成したセット数
    var actualSetCount: Int? { get }
    /// トレーニング達成成否
    var isAchieved: Bool { get }
}
