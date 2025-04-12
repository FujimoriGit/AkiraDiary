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
    
    fileprivate var defaultValue: Double {
        
        switch self {
            
        case .activityStartPeriod:
            let currentDateComponent = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            let defaultDateComponent = DateComponents(year: currentDateComponent.year,
                                                      month: currentDateComponent.month,
                                                      day: 1)
            guard let result = Calendar.current.date(from: defaultDateComponent)?.timeIntervalSince1970 else {
                
                return Date.now.timeIntervalSince1970
            }
            
            // 現在月の月初日をデフォルト値とする
            return result
        }
    }
}

extension UserDefaults {
    
    /// Double型をStorageに保存する
    func setDouble(_ value: Double, _ key: UserDefaultsDoubleKey) {
        
        set(value, forKey: key.rawValue)
    }
    
    /// 指定したKeyに対応するDouble型をStorageから取得する
    func getDouble(_ key: UserDefaultsDoubleKey) -> Double {
        
        return value(forKey: key.rawValue) as? Double ?? key.defaultValue
    }
}
