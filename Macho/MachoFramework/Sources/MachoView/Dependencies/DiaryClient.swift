//
//  FetchDiaryListClient.swift
//
//
//  Created by 佐藤汰一 on 2024/04/06.
//

import ComposableArchitecture
import Foundation
import RealmHelper

struct DiaryClient {
    
    /// 開始日付以降の日記情報の取得を行う
    /// - Parameters:
    ///   - startDate: 日記取得の開始日付
    ///   - limitCount: 日記取得上限数(0以下の場合は無制限)
    let fetch: (_ startDate: Date, _ limitCount: Int) async -> [DiaryData]
    
    /// 日記リストの情報を削除する
    /// - Parameter deleteItem: 削除対象の日記ID
    let deleteItem: (_ deleteItem: UUID) async throws(Self.Error) -> Void
    
    enum Error: Swift.Error {
        
        /// 日記の削除
        case failedDeletingItem(target: UUID)
    }
}

// MARK: 日記リスト取得APIの処理内容を注入

extension DiaryClient: DependencyKey {
    
    /// 日記リスト取得の本来の処理
    static let liveValue: DiaryClient = .createCustomValue()
    
    /// デフォルトのPreview時のモック処理
    static var previewValue = Self { _, _ in
        
        return []
    } deleteItem: { _ in
        // nop
    }
    
    /// デフォルトのTest時のモック処理
    static var testValue = Self { _, _ in
        
        return []
    } deleteItem: { _ in
        // nop
    }
    
    static func createCustomValue(_ realm: RealmAccessible = RealmAccessor()) -> DiaryClient {
        
        return DiaryClient { startDate, limitCount in
            
            return await fetchDiaryList(realm, from: startDate, limit: limitCount)
        } deleteItem: { target async throws(Self.Error) in
            
            guard await deleteDiary(realm, target: target) else {
                
                throw Error.failedDeletingItem(target: target)
            }
        }
    }
}

// MARK: - ロジック

private extension DiaryClient {
    
    static func fetchDiaryList(_ realm: RealmAccessible, from startDate: Date, limit: Int) async -> [DiaryData] {
        
        return await realm.read { diary in
            
            // 開始日付以降の日付の日記を取得対象とする
            if diary.date <= startDate { return true }
            
            return false
        }
        .prefix(limit).map(\.self)
    }
    
    static func deleteDiary(_ realm: RealmAccessible, target: UUID) async -> Bool {
        
        return await realm.delete { (diary: DiaryData) in
            
            return diary.id == target
        }
    }
}

// MARK: 日記リスト取得のAPIを登録

extension DependencyValues {
    
    var diaryListFetchApi: DiaryClient {
        
        get { self[DiaryClient.self] }
        set { self[DiaryClient.self] = newValue }
    }
}
