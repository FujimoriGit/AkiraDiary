//
//  DiaryListFilterTarget.swift
//  
//
//  Created by 佐藤汰一 on 2024/07/28.
//

enum DiaryListFilterTarget: String, CaseIterable {
    
    /// 己に勝ったかどうか
    case achievement
    /// トレーニング種別
    case trainingType
    
    enum Achievement: String, CaseIterable {
        
        /// 未達成
        case notAchieved
        /// 達成
        case achieved
        
        var title: String {
            
            switch self {
                
            case .notAchieved:
                return "達成していない"
                
            case .achieved:
                return "達成している"
            }
        }
    }
    
    var selectableCases: [String] {
        
        switch self {
            
        case .achievement:
            return Achievement.allCases.map { $0.title }
            
        case .trainingType:
            return ["腹筋", "ダンベルプレス"]
        }
    }
    
    /// フィルター種別のタイトル
    var title: String {
        
        switch self {
            
        case .achievement:
            return "目標達成有無"
            
        case .trainingType:
            return "種目"
        }
    }
    
    /// 複数選択可能なフィルターかどうか
    var isMultiSelectFilter: Bool {
        
        switch self {
            
        case .achievement:
            return false
            
        case .trainingType:
            return true
        }
    }
}
