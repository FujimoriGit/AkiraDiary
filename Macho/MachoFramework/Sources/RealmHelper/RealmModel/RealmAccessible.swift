//
//  RealmAccessible.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/09/27.
//

import Combine
import RealmSwift

public protocol RealmAccessible {
    
    /// 任意のデータをRealmDBから取得する
    ///  - Parameters:
    ///   - filterHandler:  Realm Queryで取得したいデータを指定する
    /// - Returns: 引数で指定した条件にマッチしたEntityの配列を返す
    func read<T>(where filterHandler: ((T) -> Bool)?) async -> [T] where T: BaseRealmEntity
    
    /// RealmDBにデータを保存する
    /// - Parameter records: 保存したいデータの配列
    /// - Returns: 保存に成功した場合はtrue、失敗した場合はfalseを返す
    /// 重複したレコードが存在する場合は更新する
    func insert<T>(records: [T]) async -> Bool where T: BaseRealmEntity
    
    /// RealmDBに指定したレコードのカラムを更新する
    /// - Parameters:
    ///   - type: 更新するデータの型
    ///   - value: 更新するデータの主キーと更新したいカラムをDictionary型で指定する
    /// - Returns: 更新に成功した場合はtrue、失敗した場合はfalseを返す
    /// 重複したレコードが存在する場合は更新する
    func update<T>(type: T.Type, value: [String: Any]) async -> Bool where T: BaseRealmEntity
    
    /// RealmDBに保存しているデータの削除
    /// - Returns: 削除に成功した場合はtrue、失敗した場合はfalseを返す
    func delete<T>(where filterHandler: @escaping (T) -> Bool) async -> Bool where T: BaseRealmEntity
    
    func deleteAll<T>(type: T.Type) async -> Bool where T: BaseRealmEntity
    
    /// RealmDBに保存しているすべてのデータを削除
    /// - Returns: 削除に成功した場合はtrue、失敗した場合はfalseを返す
    func truncateDb() async -> Bool
    
    /// 指定した型に対応するRealmオブジェクトテーブルの変更を監視するPublisherを返す
    /// - Parameter type: 監視するデータの型
    /// - Returns: 監視用のPublisher
    func observeDidChangeRealmObject<T>(subject: PassthroughSubject<[T], Never>)
    async -> NotificationToken? where T: BaseRealmEntity
}
