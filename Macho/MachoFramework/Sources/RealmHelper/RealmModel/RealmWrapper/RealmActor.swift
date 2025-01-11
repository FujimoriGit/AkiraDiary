//
//  RealmActor.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/16.
//

import RealmSwift

@globalActor
struct RealmActor {
    
  actor ActorType {}
    
  static let shared = ActorType()
}
