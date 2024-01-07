//
//  BaseRealmEntity.swift
//  Macho
//
//  Created by 佐藤汰一 on 2023/11/04.
//

import RealmSwift

protocol BaseRealmEntity {
    
    associatedtype RealmObject: Object
    
    /// RealmObject→Struct変換用イニシャライザ
    init(realmObject: RealmObject)
    
    /// Struct→RealmObject変換用のメソッド
    /// - Attention: RealmActorからのみ呼び出さないようにする
    func toRealmObject() -> RealmObject
}
