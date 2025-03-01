//
//  DiaryData.swift
//
//  
//  Created by Daiki Fujimori on 2024/08/31
//  

import Foundation

public protocol DiaryData: Equatable, Sendable, Identifiable {
    
    associatedtype GoalType: TrainingContentData
    associatedtype TagType: TrainingTagData
    
    var id: UUID { get }
    /// 日付
    var date: Date { get }
    /// 日記タイトル
    var title: String { get }
    /// 日記本文
    var mainText: String { get }
    /// 目標種目リスト
    var  goals: [GoalType] { get }
    /// タグリスト
    var tags: [TagType] { get }
    /// 開始時間
    var startTime: Date? { get }
    /// 終了時間
    var endTime: Date? { get }
    /// 全ての目標を達成したかどうか
    var isAchieved: Bool { get }
}
