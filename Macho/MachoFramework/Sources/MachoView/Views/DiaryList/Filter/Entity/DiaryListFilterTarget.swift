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
    /// タグ
    case tag
    
    /// 種別毎の番号
    var num: Int {
        
        switch self {
            
        case .achievement:
            return 0
            
        case .trainingType:
            return 1
            
        case .tag:
            return 2
        }
    }
    
    /// フィルター種別のタイトル
    var title: String {
        
        switch self {
            
        case .achievement:
            return "目標達成有無"
            
        case .trainingType:
            return "種目"
            
        case .tag:
            return "タグ"
        }
    }
    
    /// 複数選択可能なフィルターかどうか
    var isMultiSelectFilter: Bool {
        
        switch self {
            
        case .achievement:
            return false
            
        case .trainingType:
            return true
            
        case .tag:
            return true
        }
    }
}

enum TrainingAchievement: Int, CaseIterable {
    
    /// 未達成
    case notAchieved
    /// 達成
    case achieved
    
    init?(value: String) {
        
        guard let achievement = Self.allCases.first(where: { value == $0.title }) else { return nil }
        self = achievement
    }
    
    var title: String {
        
        switch self {
            
        case .notAchieved:
            return "達成していない"
            
        case .achieved:
            return "達成している"
        }
    }
}
