//
//  UserDefaultsArrayStringKey.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/26.
//

import Foundation

enum UserDefaultsArrayStringKey: String {
    
    /// 表示トレーニングリスト
    case targetTrainingTypeList
}

extension UserDefaults {
    
    /// Stringの配列型をStorageに保存する
    func setStringArray(_ value: [String], _ key: UserDefaultsArrayStringKey) {
        
        set(value, forKey: key.rawValue)
    }
    
    /// 指定したKeyに対応するStringの配列型をStorageから取得する
    func getStringArray(_ key: UserDefaultsArrayStringKey) -> [String] {
        
        return self.stringArray(forKey: key.rawValue) ?? []
    }
}
