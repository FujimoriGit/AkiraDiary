//
//  DiaryEntity.swift
//
//  
//  Created by Daiki Fujimori on 2024/08/31
//  

import Foundation
import MachoCore
import RealmHelper
import RealmSwift

public struct DiaryEntity: BaseRealmEntity, DiaryData {
    
    public typealias GoalType = TrainingContentEntity
    public typealias TagType = TrainingTagEntity
    
    public let id: UUID
    /// 日付
    public let date: Date
    /// 日記タイトル
    public let title: String
    /// 日記本文
    public let mainText: String
    /// 目標リスト
    public let goals: [TrainingContentEntity]
    /// タグリスト
    public let tags: [TrainingTagEntity]
    /// 開始時間
    public let startTime: Date?
    /// 終了時間
    public let endTime: Date?
    
    /// 全ての目標を達成したかどうか
    public var isAchieved: Bool {
        
        return !goals.contains { !$0.isAchieved }
    }
    
    public init(id: UUID,
                date: Date,
                title: String,
                mainText: String,
                goals: [TrainingContentEntity],
                tags: [TrainingTagEntity],
                startTime: Date?,
                endTime: Date?) {
        
        self.id = id
        self.date = date
        self.title = title
        self.mainText = mainText
        self.goals = goals
        self.tags = tags
        self.startTime = startTime
        self.endTime = endTime
    }
    
    public init(realmObject: DiaryRealmObject) {
        
        id = realmObject.id
        date = realmObject.date
        title = realmObject.title
        mainText = realmObject.mainText
        goals = realmObject.goals.map { TrainingContentEntity(realmObject: $0) }
        tags = realmObject.tags.map { TrainingTagEntity(realmObject: $0) }
        startTime = realmObject.startTime
        endTime = realmObject.endTime
    }
    
    init(_ data: some DiaryData) {
        
        id = data.id
        date = data.date
        title = data.title
        mainText = data.mainText
        goals = data.goals.map { TrainingContentEntity($0) }
        tags = data.tags.map { TrainingTagEntity($0) }
        startTime = data.startTime
        endTime = data.endTime
    }
    
    public func toRealmObject() -> DiaryRealmObject {
        
        let goalObjects = goals.reduce(List<TrainingContentRealmObject>()) {
            
            $0.append($1.toRealmObject())
            return $0
        }
        
        let tagObjects = tags.reduce(List<TrainingTagRealmObject>()) {
            
            $0.append($1.toRealmObject())
            return $0
        }
        
        return DiaryRealmObject(id: id,
                                date: date,
                                title: title,
                                mainText: mainText,
                                goals: goalObjects,
                                tags: tagObjects,
                                startTime: startTime,
                                endTime: endTime)
    }
}

public class DiaryRealmObject: Object {
    
    @Persisted(primaryKey: true)
    var id: UUID
    /// 日付
    @Persisted var date: Date
    /// 日記タイトル
    @Persisted var title: String
    /// 日記本文
    @Persisted var mainText: String
    /// 目標種目リスト
    @Persisted var goals: List<TrainingContentRealmObject>
    /// タグリスト
    @Persisted var tags: List<TrainingTagRealmObject>
    /// 開始時間
    @Persisted var startTime: Date?
    /// 終了時間
    @Persisted var endTime: Date?
    
    convenience init(id: UUID,
                     date: Date,
                     title: String,
                     mainText: String,
                     goals: List<TrainingContentRealmObject>,
                     tags: List<TrainingTagRealmObject>,
                     startTime: Date?,
                     endTime: Date?) {
        
        self.init()
        
        self.id = id
        self.date = date
        self.title = title
        self.mainText = mainText
        self.goals = goals
        self.tags = tags
        self.startTime = startTime
        self.endTime = endTime
    }
}

extension ConcreteDiaryData {
    
    init(entity: DiaryEntity) {
        
        self.init(id: entity.id,
                  date: entity.date,
                  title: entity.title,
                  mainText: entity.mainText,
                  goals: entity.goals.map { .init(entity: $0) },
                  tags: entity.tags.map { .init(id: $0.id, tagName: $0.tagName) },
                  startTime: entity.startTime,
                  endTime: entity.endTime)
    }
}
