//
//  RealmActor.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/30.
//

import RealmSwift

@globalActor
public struct RealmActor {
    
    public static var shared = ActorType()
    
    public actor ActorType {}
}
