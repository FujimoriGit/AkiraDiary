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
    case emptyDiaryItemAlert // 日記が一件も存在しない場合のアラート
    case confirmNoSavingDiary // 日記が保存されないことを確認するアラート
}

// MARK: - アラートのタイトル

extension AlertType {
    
    var title: String {
        
        switch self {
            
        case .deleteDiaryItemConfirmAlert:
            return "日記の削除しますか？"
            
        case .editDiaryItemConfirmAlert:
            return "日記の編集を行いますか？"
        
        case .emptyDiaryItemAlert:
            return "まだ日記が一度も作成されていません。"
            + "\n"
            + "日記を作成してみましょう!"
            
        case .confirmNoSavingDiary:
            return "作成画面から離れると、入力した内容は削除されてしまいますがよろしいですか？"
        }
    }
}

// MARK: - アラートのメッセージ

extension AlertType {
    
    var message: String? {
        
        switch self {
            
        case .deleteDiaryItemConfirmAlert,
                .editDiaryItemConfirmAlert,
                .emptyDiaryItemAlert,
                .confirmNoSavingDiary:
            return nil
        }
    }
}

// MARK: - アラートの第1ボタンタイトル

extension AlertType {
    
    var firstButtonTitle: String {
        
        switch self {
            
        case .deleteDiaryItemConfirmAlert,
                .editDiaryItemConfirmAlert,
                .emptyDiaryItemAlert,
                .confirmNoSavingDiary:
            return "OK"
        }
    }
}

// MARK: - アラートの第2ボタンタイトル

extension AlertType {
    
    var secondButtonTitle: String? {
        
        switch self {
            
        case .deleteDiaryItemConfirmAlert,
                .editDiaryItemConfirmAlert,
                .emptyDiaryItemAlert,
                .confirmNoSavingDiary:
            return nil
        }
    }
}
