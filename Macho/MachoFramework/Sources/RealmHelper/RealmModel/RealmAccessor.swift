//
//  RealmAccessor.swift
//  Macho
//
//  Created by 佐藤汰一 on 2023/11/04.
//

import Combine
import RealmSwift

public struct RealmAccessor: RealmAccessible {
    
    private let realm: RealmActor
    
    // MARK: - RealmAccessor initialize method
    public init() async {
        
        realm = await RealmActor.getSingleton()
    }
    
    // MARK: - RealmAccessor public methods
    
    /// 任意のデータをRealmDBから取得する
    ///  - Parameters:
    ///   - filterHandler:  Realm Queryで取得したいデータを指定する
    /// - Returns: 引数で指定した条件にマッチしたEntityの配列を返す
    public func read<T>(where filterHandler: ((T) -> Bool)? = nil) async -> [T] where T: BaseRealmEntity {
        
        let result: [T] = await self.realm.read()
        guard let filterHandler else { return result }
        
        return result.filter(filterHandler)
    }
    
    /// RealmDBにデータを保存する
    /// - Parameter records: 保存したいデータの配列
    /// - Returns: 保存に成功した場合はtrue、失敗した場合はfalseを返す
    /// 重複したレコードが存在する場合は更新する
    public func insert<T>(records: [T]) async -> Bool where T: BaseRealmEntity {
        
        return await self.realm.insert(records: records)
    }
    
    /// RealmDBに指定したレコードのカラムを更新する
    /// - Parameters:
    ///   - type: 更新するデータの型
    ///   - value: 更新するデータの主キーと更新したいカラムをDictionary型で指定する
    /// - Returns: 更新に成功した場合はtrue、失敗した場合はfalseを返す
    /// 重複したレコードが存在する場合は更新する
    public func update<T>(type: T.Type, value: [String: Any]) async -> Bool where T: BaseRealmEntity {
        
        return await self.realm.update(type: type, value: value)
    }
    
    /// RealmDBに保存しているデータの削除
    /// - Returns: 削除に成功した場合はtrue、失敗した場合はfalseを返す
    public func delete<T>(where filterHandler: @escaping (T) -> Bool) async -> Bool where T: BaseRealmEntity {
        
        return await self.realm.delete(where: filterHandler)
    }
    
    public func deleteAll<T>(type: T.Type) async -> Bool where T: BaseRealmEntity {
        
        return await self.realm.deleteAll(type: type)
    }
    
    /// RealmDBに保存しているすべてのデータを削除
    /// - Returns: 削除に成功した場合はtrue、失敗した場合はfalseを返す
    public func truncateDb() async -> Bool {
        
        return await self.realm.truncateDb()
    }
    
    /// 指定した型に対応するRealmオブジェクトテーブルの変更を監視するPublisherを返す
    /// - Parameter type: 監視するデータの型
    /// - Returns: 監視用のPublisher
    public func observeDidChangeRealmObject<T>(subject: PassthroughSubject<[T], Never>)
    async -> NotificationToken? where T: BaseRealmEntity {
        
        return await realm.readObjectsForObserve(type: T.self) { updateSnapshot in
            
            subject.send(updateSnapshot)
        }
    }
}

fileprivate actor RealmActor {
    
    private static var singletonTask: Task<RealmActor, Never>?
    private var realm: Realm?
    
    // MARK: - RealmActor initialize method
    private init() async {
        
        realm = try? await Realm(actor: self)
    }
    
    static func getSingleton() async -> RealmActor {
        
        if let singletonTask {
            
            return await singletonTask.value
        }
        
        let task = Task { await RealmActor() }
        singletonTask = task
        return await task.value
    }
    
    // MARK: - RealmActor public methods
    
    /// 任意のデータをRealmDBから取得する
    ///   - type: 取得したいデータの型
    /// - Returns: 引数で指定したデータ型のレコード配列を返す
    func read<T>() -> [T] where T: BaseRealmEntity {
        
        guard let result = realm?.objects(T.RealmObject.self) else { return [] }
        return toUnManagedObject(result)
    }
    
    /// RealmDBにデータを保存する
    /// - Parameter records: 保存したいデータの配列
    /// 重複したレコードが存在する場合は更新する
    func insert<T>(records: [T]) async -> Bool where T: BaseRealmEntity {
        
        let realmRecords = records.map { $0.toRealmObject() }
        return await executeAsyncWrite { [realm = self.realm] in
            
            realmRecords.forEach { realm?.add($0, update: .modified) }
        }
    }
    
    /// RealmDBに指定したレコードのカラムを非同期で更新する
    /// - Parameters:
    ///   - type: 更新するデータの型
    ///   - value: 更新するデータの主キーと更新したいカラムをDictionary型で指定する
    /// 重複したレコードが存在する場合は更新する
    func update<T>(type: T.Type, value: [String: Any]) async -> Bool where T: BaseRealmEntity {
        
        return await executeAsyncWrite { [realm = self.realm] in
            
            realm?.create(type.RealmObject, value: value, update: .modified)
        }
    }
    
    /// RealmDBに保存しているデータを非同期で削除
    /// - Parameter records: 削除したいレコードの配列
    /// - Parameter filterHandler: 削除するレコードの条件
    /// - Returns: 削除が成功したかどうか
    func delete<T>(where filterHandler: @escaping (T) -> Bool) async -> Bool where T: BaseRealmEntity {
        
        guard let targetRecords = realm?.objects(T.RealmObject.self).filter({
            
            filterHandler(T(realmObject: $0))
        }) else { return false }
        
        return await executeAsyncWrite { [realm = self.realm] in
            
            targetRecords.forEach { realm?.delete($0) }
        }
    }
    
    /// 指定のテーブルのデータを全て削除
    /// - Parameter type: 削除するデータの型
    /// - Returns: 削除が成功したかどうか
    func deleteAll<T>(type: T.Type) async -> Bool where T: BaseRealmEntity {
        
        guard let objects = self.realm?.objects(type.RealmObject.self) else { return false }
        
        return await executeAsyncWrite { [unowned self] in
            
            self.realm?.delete(objects)
        }
    }
    
    /// RealmDBに保存しているすべてのデータを削除
    func truncateDb() async -> Bool {
        
        return await executeAsyncWrite { [realm = self.realm] in
            
            realm?.deleteAll()
        }
    }
    
    /// 任意のデータタイプのRealmDBの変更を検知を監視を開始する
    /// - Parameters:
    ///   - type: 監視するデータタイプ
    ///   - updateHandler: 変更したRealmデータをStructとして通知するコールバックハンドラ
    /// - Returns: 監視のSubscribeを制御するToken
    func readObjectsForObserve<T>(type: T.Type,
                                  updateHandler: @escaping ([T]) -> Void) async -> NotificationToken?
    where T: BaseRealmEntity {
        
        return await realm?.objects(type.RealmObject).observe(on: self) { _, snapshot in
            
            switch snapshot {
                
            case .initial(let initial):
                updateHandler(self.toUnManagedObject(initial))
                
            case .update(let update, _, _, _):
                updateHandler(self.toUnManagedObject(update))
                
            case .error(let error):
                logger.error("Occurred realm observe error: \(error), type: \(type)")
            }
        }
    }
}

// MARK: - RealmActor private methods
private extension RealmActor {
    
    func executeAsyncWrite(_ operation: @escaping () -> Void) async -> Bool {
        
        return await withCheckedContinuation { continuation in
            
            realm?.writeAsync(operation) { error in
                
                guard let error else {
                    
                    continuation.resume(returning: true)
                    return
                }
                
                logger.error("Failed realm operation: \(error)")
                continuation.resume(returning: false)
            }
        }
    }
    
    /// Realmオブジェクトの結果をStructの型に変換する
    /// - Parameter results: Realmから取得したResultオブジェクト
    /// - Returns: Resultオブジェクトに対応するStructの配列を返す
    nonisolated func toUnManagedObject<T>(_ results: Results<T.RealmObject>) -> [T] where T: BaseRealmEntity {
        
        return Array(results).map { T(realmObject: $0) }
    }
}
