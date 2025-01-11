//
//  RealmAccessor.swift
//  Macho
//
//  Created by 佐藤汰一 on 2023/11/04.
//

import Combine
import RealmSwift

public struct RealmAccessor: RealmAccessible {
        
    // MARK: - RealmAccessor initialize method
    
    public init() {
        // nop
    }
    
    // MARK: - RealmAccessor public methods
    
    /// 任意のデータをRealmDBから取得する
    ///  - Parameters:
    ///   - filterHandler:  Realm Queryで取得したいデータを指定する
    /// - Returns: 引数で指定した条件にマッチしたEntityの配列を返す
    public func read<T>(where filterHandler: ((T) -> Bool)? = nil) async -> [T] where T: BaseRealmEntity {
        
        let result: [T] = await RealmWrapper.shared.read()
        guard let filterHandler else { return result }
        
        return result.filter(filterHandler)
    }
    
    /// RealmDBにデータを保存する
    /// - Parameter records: 保存したいデータの配列
    /// - Returns: 保存に成功した場合はtrue、失敗した場合はfalseを返す
    /// 重複したレコードが存在する場合は更新する
    public func insert<T>(records: [T]) async -> Bool where T: BaseRealmEntity {
        
        return await RealmWrapper.shared.insert(records: records)
    }
    
    /// RealmDBに指定したレコードのカラムを更新する
    /// - Parameters:
    ///   - type: 更新するデータの型
    ///   - value: 更新するデータの主キーと更新したいカラムをDictionary型で指定する
    /// - Returns: 更新に成功した場合はtrue、失敗した場合はfalseを返す
    /// 重複したレコードが存在する場合は更新する
    public func update<T>(type: T.Type, value: [String: Any]) async -> Bool where T: BaseRealmEntity {
        
        return await RealmWrapper.shared.update(type: type, value: value)
    }
    
    /// RealmDBに保存しているデータの削除
    /// - Returns: 削除に成功した場合はtrue、失敗した場合はfalseを返す
    public func delete<T>(where filterHandler: @escaping (T) -> Bool) async -> Bool where T: BaseRealmEntity {
        
        return await RealmWrapper.shared.delete(where: filterHandler)
    }
    
    public func deleteAll<T>(type: T.Type) async -> Bool where T: BaseRealmEntity {
        
        return await RealmWrapper.shared.deleteAll(type: type)
    }
    
    /// RealmDBに保存しているすべてのデータを削除
    /// - Returns: 削除に成功した場合はtrue、失敗した場合はfalseを返す
    public func truncateDb() async -> Bool {
        
        return await RealmWrapper.shared.truncateDb()
    }
    
    /// 指定した型に対応するRealmオブジェクトテーブルの変更を監視するPublisherを返す
    /// - Parameter type: 監視するデータの型
    /// - Returns: 監視用のPublisher
    public func observeDidChangeRealmObject<T>(subject: PassthroughSubject<[T], Never>)
    async -> NotificationToken? where T: BaseRealmEntity {
        
        return await RealmWrapper.shared.readObjectsForObserve(type: T.self) { updateSnapshot in
            
            subject.send(updateSnapshot)
        }
    }
}
