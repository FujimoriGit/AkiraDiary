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

extension DiaryData: BaseRealmEntity {
    
    public init(realmObject: DiaryRealmObject) {
        
        self.init(
            id: realmObject.id,
            date: realmObject.date,
            title: realmObject.title,
            mainText: realmObject.mainText,
            goals: realmObject.goals.map { .init(realmObject: $0) },
            tags: realmObject.tags.map { .init(realmObject: $0) },
            startTime: realmObject.startTime,
            endTime: realmObject.endTime
        )
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
