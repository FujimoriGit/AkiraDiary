//
//  RealmAccessor.swift
//  Macho
//
//  Created by 佐藤汰一 on 2023/11/04.
//

import Combine
import MachoCore
import RealmSwift

public struct RealmAccessor: RealmAccessible {
    
    // MARK: - private property
    
    private let realm: RealmWrapper
        
    // MARK: - RealmAccessor initialize method
    
    init(_ config: DbConfiguration) async throws {
        
        realm = try await RealmWrapper(config)
    }
    
    // MARK: - RealmAccessor public methods
    
    /// 任意のデータをRealmDBから取得する
    ///  - Parameters:
    ///   - filterHandler:  Realm Queryで取得したいデータを指定する
    /// - Returns: 引数で指定した条件にマッチしたEntityの配列を返す
    public func read<T>(where filterHandler: ((T) -> Bool)? = nil) async -> [T] where T: BaseRealmEntity {
        
        let result: [T] = await realm.read()
        guard let filterHandler else { return result }
        
        return result.filter(filterHandler)
    }
    
    /// RealmDBにデータを保存する
    /// - Parameter records: 保存したいデータの配列
    /// - Returns: 保存に成功した場合はtrue、失敗した場合はfalseを返す
    /// 重複したレコードが存在する場合は更新する
    public func insert<T>(records: [T]) async -> Bool where T: BaseRealmEntity {
        
        return await realm.insert(records: records)
    }
    
    /// RealmDBに指定したレコードのカラムを更新する
    /// - Parameters:
    ///   - type: 更新するデータの型
    ///   - value: 更新するデータの主キーと更新したいカラムをDictionary型で指定する
    /// - Returns: 更新に成功した場合はtrue、失敗した場合はfalseを返す
    /// 重複したレコードが存在する場合は更新する
    public func update<T>(type: T.Type, value: [String: Any]) async -> Bool where T: BaseRealmEntity {
        
        return await realm.update(type: type, value: value)
    }
    
    /// RealmDBに保存しているデータの削除
    /// - Returns: 削除に成功した場合はtrue、失敗した場合はfalseを返す
    public func delete<T>(where filterHandler: @escaping (T) -> Bool) async -> Bool where T: BaseRealmEntity {
        
        return await realm.delete(where: filterHandler)
    }
    
    public func deleteAll<T>(type: T.Type) async -> Bool where T: BaseRealmEntity {
        
        return await realm.deleteAll(type: type)
    }
    
    /// RealmDBに保存しているすべてのデータを削除
    /// - Returns: 削除に成功した場合はtrue、失敗した場合はfalseを返す
    public func truncateDb() async -> Bool {
        
        return await realm.truncateDb()
    }
    
    /// 指定した型に対応するRealmオブジェクトテーブルの変更を監視するPublisherを返す
    /// - Parameter type: 監視するデータの型
    /// - Returns: 監視用のPublisher
    public func getEntityChangeObserver<T>()
    async -> AnyPublisher<[T], Never> where T: BaseRealmEntity {
        
        return await realm.readObjectsForObserve(type: T.self)
    }
}
