//
//  RealmWrapper.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/30.
//

import Combine
import MachoCore
import RealmSwift

@RealmActor
struct RealmWrapper {
    
    private let realm: Realm
    
    // MARK: - RealmActor initialize method
    
    init(_ config: DbConfiguration) async throws {
        
        let configuration = if let fileUrl = config.url {
            
            Realm.Configuration(fileURL: fileUrl,
                                schemaVersion: config.version)
        }
        else {
            
            Realm.Configuration(inMemoryIdentifier: config.isOnMemoryId,
                                schemaVersion: config.version)
        }
        
        logger.debug("realm config: \(config)")
        realm = try await Realm(configuration: configuration,
                                actor: RealmActor.shared)
        logger.info("Completed setup realm.")
    }
    
    // MARK: - RealmActor public methods
    
    /// 任意のデータをRealmDBから取得する
    ///   - type: 取得したいデータの型
    /// - Returns: 引数で指定したデータ型のレコード配列を返す
    func read<T>() -> [T] where T: BaseRealmEntity {
        
        let result = realm.objects(T.RealmObject.self)
        return toUnManagedObject(result)
    }
    
    /// RealmDBにデータを保存する
    /// - Parameter records: 保存したいデータの配列
    /// 重複したレコードが存在する場合は更新する
    func insert<T>(records: [T]) async -> Bool where T: BaseRealmEntity {
        
        let realmRecords = records.map { $0.toRealmObject() }
        return await executeAsyncWrite { [realm = self.realm] in
            
            realmRecords.forEach { realm.add($0, update: .modified) }
        }
    }
    
    /// RealmDBに指定したレコードのカラムを非同期で更新する
    /// - Parameters:
    ///   - type: 更新するデータの型
    ///   - value: 更新するデータの主キーと更新したいカラムをDictionary型で指定する
    /// 重複したレコードが存在する場合は更新する
    func update<T>(type: T.Type, value: [String: Any]) async -> Bool where T: BaseRealmEntity {
        
        return await executeAsyncWrite { [realm = self.realm] in
            
            realm.create(type.RealmObject, value: value, update: .modified)
        }
    }
    
    /// RealmDBに保存しているデータを非同期で削除
    /// - Parameter records: 削除したいレコードの配列
    /// - Parameter filterHandler: 削除するレコードの条件
    /// - Returns: 削除が成功したかどうか
    func delete<T>(where filterHandler: @escaping (T) -> Bool) async -> Bool where T: BaseRealmEntity {
        
        let targetRecords = realm.objects(T.RealmObject.self)
            .filter {
                
                filterHandler(T(realmObject: $0))
            }
        return await executeAsyncWrite { [realm = self.realm] in
            
            targetRecords.forEach { realm.delete($0) }
        }
    }
    
    /// 指定のテーブルのデータを全て削除
    /// - Parameter type: 削除するデータの型
    /// - Returns: 削除が成功したかどうか
    func deleteAll<T>(type: T.Type) async -> Bool where T: BaseRealmEntity {
        
        let objects = self.realm.objects(type.RealmObject.self)
        return await executeAsyncWrite { [realm] in
            
            realm.delete(objects)
        }
    }
    
    /// RealmDBに保存しているすべてのデータを削除
    func truncateDb() async -> Bool {
        
        return await executeAsyncWrite { [realm = self.realm] in
            
            realm.deleteAll()
        }
    }
    
    /// 任意のデータタイプのRealmDBの変更を検知を監視を開始する
    /// - Parameters:
    ///   - type: 監視するデータタイプ
    ///   - updateHandler: 変更したRealmデータをStructとして通知するコールバックハンドラ
    /// - Returns: 監視のSubscribeを制御するToken
    func readObjectsForObserve<T>(type: T.Type) async -> AnyPublisher<[T], Never>
    where T: BaseRealmEntity {
        
        let publisher = RealmObservePublisher<[T]>()
        let token = await realm.objects(type.RealmObject)
            .observe(on: RealmActor.shared) { _, snapshot in
                
                logger.debug("[In] type: \(type), snapshot: \(snapshot)")
                
                switch snapshot {
                    
                case .initial(let initial):
                    publisher.send(toUnManagedObject(initial))
                    
                case .update(let update, _, _, _):
                    publisher.send(toUnManagedObject(update))
                    
                case .error(let error):
                    logger.error("Occurred realm observe error: \(error), type: \(type)")
                }
            }
        
        publisher.setToken(token)
        return publisher.eraseToAnyPublisher()
    }
    
//    enum DbObserveResult<T: BaseRealmEntity> {
//        
//        case initial([T])
//        case update([T])
//    }
    
//    func readObjectsForObserve<T>(type: T.Type) async -> AsyncStream<DbObserveResult<T>>
//    where T: BaseRealmEntity {
//                
//        let objects = realm.objects(type.RealmObject)
//            
//        let stream = AsyncStream<DbObserveResult<T>> { @RealmActor continuation in
//        
//            let token = objects.observe { snapshot in
//                    
//                    switch snapshot {
//                        
//                    case .initial(let initial):
//                        continuation.yield(.initial(toUnManagedObject(initial)))
//                        
//                    case .update(let update, _, _, _):
//                        continuation.yield(.update(toUnManagedObject(update)))
//                        
//                    case .error(let error):
//                        logger.error("Occurred realm observe error: \(error), type: \(type)")
//                    }
//                }
//        }
//        return stream
//    }
//    
//    func readObjectsForObserve<T>(type: T.Type) async -> AnyPublisher<[T], Never>
//    where T: BaseRealmEntity {
//        
//        return realm.objects(type.RealmObject).changesetPublisher
//            .map {
//                
//                switch $0 {
//                    
//                case .initial(let results), .update(let results, _, _, _):
//                    return results.map { T(realmObject: $0) }
//                
//                case .error(let error):
//                    logger.error("Occurred realm observe error: \(error), type: \(type)")
//                    return []
//                }
//            }
//            .replaceError(with: [])
//            .eraseToAnyPublisher()
//    }
}

// MARK: - RealmActor private methods

private extension RealmWrapper {
    
    func executeAsyncWrite(_ operation: @escaping () -> Void) async -> Bool {
        
        return await withCheckedContinuation { continuation in
            
            realm.writeAsync(operation) { error in
                
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
