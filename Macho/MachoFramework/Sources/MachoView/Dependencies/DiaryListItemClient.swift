//
//  FetchDiaryListClient.swift
//
//
//  Created by 佐藤汰一 on 2024/04/06.
//

import ComposableArchitecture
import Foundation

struct DiaryListItemClient {
    
    // TODO: 戻り値の型を日記アイテムに変える
    /// 日記リストの取得を行う
    /// - Parameters:
    ///   - startDate: 日記取得の開始日付
    ///   - limitCount: 日記取得上限数(0以下の場合は無制限)
    let fetch: (_ startDate: Date, _ limitCount: Int) async throws -> [DiaryListItemFeature.State]
    
    /// 日記リストの情報を削除する
    /// - Parameter deleteItem: 削除対象の日記ID
    let deleteItem: (_ deleteItem: UUID) async throws -> Void
}

// MARK: 日記リスト取得APIの処理内容を注入

extension DiaryListItemClient: DependencyKey {
    
    /// 日記リスト取得の本来の処理
    static let liveValue = Self { fetchStartDate, limitCount  in
        
        // TODO: 日記の情報を返す
        return []
    } deleteItem: { uuid in
        
        // TODO: パラメータのUUIDから日記の情報をDBから削除する
    }
    
    /// デフォルトのPreview時のモック処理
    static var previewValue = Self { _, _ in
        
        return [.init(title: "preview", message: "reload message", date: Date(), isWin: false)]
    } deleteItem: { _ in }
    
    /// デフォルトのTest時のモック処理
    static var testValue = Self { _, _ in
        
        return [.init(title: "test", message: "reload message", date: Date(timeIntervalSince1970: .zero), isWin: false)]
    } deleteItem: { _ in }
}

// MARK: 日記リスト取得のAPIを登録

extension DependencyValues {
    
    var diaryListFetchApi: DiaryListItemClient {
        
        get { self[DiaryListItemClient.self] }
        set { self[DiaryListItemClient.self] = newValue }
    }
}
