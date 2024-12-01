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
    /// 目標種目リスト
    public let goals: [GoalType]
    /// タグリスト
    public let tags: [TagType]
    
    public init(id: UUID,
                date: Date,
                title: String,
                mainText: String,
                goals: [TrainingContentEntity],
                tags: [TrainingTagEntity]) {
        
        self.id = id
        self.date = date
        self.title = title
        self.mainText = mainText
        self.goals = goals
        self.tags = tags
    }
    
    public init(realmObject: DiaryRealmObject) {
        
        id = realmObject.id
        date = realmObject.date
        title = realmObject.title
        mainText = realmObject.mainText
        goals = realmObject.goals.map { TrainingContentEntity(realmObject: $0) }
        tags = realmObject.tags.map { TrainingTagEntity(realmObject: $0) }
    }
    
    init(_ data: some DiaryData) {
        
        id = data.id
        date = data.date
        title = data.title
        mainText = data.mainText
        goals = data.goals.map { TrainingContentEntity($0) }
        tags = data.tags.map { TrainingTagEntity($0) }
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
                                tags: tagObjects)
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
    
    convenience init(id: UUID,
                     date: Date,
                     title: String,
                     mainText: String,
                     goals: List<TrainingContentRealmObject>,
                     tags: List<TrainingTagRealmObject>) {
        
        self.init()
        
        self.id = id
        self.date = date
        self.title = title
        self.mainText = mainText
        self.goals = goals
        self.tags = tags
    }
}
