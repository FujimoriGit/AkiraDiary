//
//  AlertType.swift
//
//
//  Created by 佐藤汰一 on 2024/06/08.
//

import ComposableArchitecture

enum AlertType {
    
    case deleteDiaryItemConfirmAlert // 日記項目削除時の確認アラート
    case editDiaryItemConfirmAlert // 日記項目編集時の確認アラート
    case failedLoadDiaryItemsAlert // 日記リスト取得失敗のアラート
}

// MARK: - アラートのタイトル

extension AlertType {
    
    var title: String {
        
        switch self {
            
        case .deleteDiaryItemConfirmAlert:
            return "日記の削除しますか？"
            
        case .editDiaryItemConfirmAlert:
            return "日記の編集を行いますか？"
            
        case .failedLoadDiaryItemsAlert:
            return "日記の取得に失敗しました"
        }
    }
}

// MARK: - アラートのメッセージ

extension AlertType {
    
    var message: String? {
        
        switch self {
            
        case .deleteDiaryItemConfirmAlert, .editDiaryItemConfirmAlert, .failedLoadDiaryItemsAlert:
            return nil
        }
    }
}

// MARK: - アラートの第1ボタンタイトル

extension AlertType {
    
    var firstButtonTitle: String {
        
        switch self {
            
        case .deleteDiaryItemConfirmAlert, .editDiaryItemConfirmAlert, .failedLoadDiaryItemsAlert:
            return "OK"
        }
    }
}

// MARK: - アラートの第2ボタンタイトル

extension AlertType {
    
    var secondButtonTitle: String? {
        
        switch self {
            
        case .deleteDiaryItemConfirmAlert, .editDiaryItemConfirmAlert, .failedLoadDiaryItemsAlert:
            return nil
        }
    }
}
