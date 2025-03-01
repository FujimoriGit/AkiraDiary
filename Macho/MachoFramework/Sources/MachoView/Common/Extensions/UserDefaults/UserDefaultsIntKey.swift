//
//  UserDefaultsKey.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/26.
//

import Foundation

enum UserDefaultsIntKey: String {
    
    /// グラフ表示期間
    case activityPeriod
}

extension UserDefaults {
    
    /// Int型をStorageに保存する
    func setInt(_ value: Int, _ key: UserDefaultsIntKey) {
        
        set(value, forKey: key.rawValue)
    }
    
    /// 指定したKeyに対応するInt型をStorageから取得する
    func getInt(_ key: UserDefaultsIntKey) -> Int {
        
        return integer(forKey: key.rawValue)
    }
}
