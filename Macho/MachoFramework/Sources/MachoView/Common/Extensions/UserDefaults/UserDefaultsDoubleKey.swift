//
//  UserDefaultsDoubleKey.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/26.
//

import Foundation

enum UserDefaultsDoubleKey: String {
    
    /// グラフ表示開始日付
    case activityStartPeriod
}

extension UserDefaults {
    
    /// Double型をStorageに保存する
    func setDouble(_ value: Double, _ key: UserDefaultsDoubleKey) {
        
        set(value, forKey: key.rawValue)
    }
    
    /// 指定したKeyに対応するDouble型をStorageから取得する
    func getDouble(_ key: UserDefaultsDoubleKey) -> Double {
        
        return double(forKey: key.rawValue)
    }
}
