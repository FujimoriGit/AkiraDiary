//
//  RealmWrapper.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/22.
//

import RealmSwift

@RealmActor
final class RealmWrapper {
    
    static let shared = RealmWrapper()
    private let realm = RealmFactory.make()
    
    // MARK: - RealmActor public methods
    
    /// 任意のデータをRealmDBから取得する
    ///   - type: 取得したいデータの型
    /// - Returns: 引数で指定したデータ型のレコード配列を返す
    func read<T>() async -> [T] where T: BaseRealmEntity {
        
        let result = await getRealm().objects(T.RealmObject.self)
        return toUnManagedObject(result)
    }
    
    /// RealmDBにデータを保存する
    /// - Parameter records: 保存したいデータの配列
    /// 重複したレコードが存在する場合は更新する
    func insert<T>(records: [T]) async -> Bool where T: BaseRealmEntity {
        
        let realmRecords = records.map { $0.toRealmObject() }
        let realm = await getRealm()
        return await executeAsyncWrite {
            
            realmRecords.forEach { realm.add($0, update: .modified) }
        }
    }
    
    /// RealmDBに指定したレコードのカラムを非同期で更新する
    /// - Parameters:
    ///   - type: 更新するデータの型
    ///   - value: 更新するデータの主キーと更新したいカラムをDictionary型で指定する
    /// 重複したレコードが存在する場合は更新する
    func update<T>(type: T.Type, value: [String: Any]) async -> Bool where T: BaseRealmEntity {
        
        let realm = await getRealm()
        return await executeAsyncWrite {
            
            realm.create(type.RealmObject, value: value, update: .modified)
        }
    }
    
    /// RealmDBに保存しているデータを非同期で削除
    /// - Parameter records: 削除したいレコードの配列
    /// - Parameter filterHandler: 削除するレコードの条件
    /// - Returns: 削除が成功したかどうか
    func delete<T>(where filterHandler: @escaping (T) -> Bool) async -> Bool where T: BaseRealmEntity {
        
        let realm = await getRealm()
        let targetRecords = realm.objects(T.RealmObject.self).filter {
            
            filterHandler(T(realmObject: $0))
        }
        
        return await executeAsyncWrite {
            
            targetRecords.forEach { realm.delete($0) }
        }
    }
    
    /// 指定のテーブルのデータを全て削除
    /// - Parameter type: 削除するデータの型
    /// - Returns: 削除が成功したかどうか
    func deleteAll<T>(type: T.Type) async -> Bool where T: BaseRealmEntity {
        
        let realm = await getRealm()
        let objects = realm.objects(type.RealmObject.self)
        
        return await executeAsyncWrite {
            
            realm.delete(objects)
        }
    }
    
    /// RealmDBに保存しているすべてのデータを削除
    func truncateDb() async -> Bool {
        
        let realm = await getRealm()
        return await executeAsyncWrite {
            
            realm.deleteAll()
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
        
        let realm = await getRealm()
        return await realm.objects(type.RealmObject)
            .observe(on: RealmActor.shared) { _, snapshot in
                
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

private extension RealmWrapper {
    
    func getRealm() async -> Realm {
        
        return await realm.value
    }
    
    func executeAsyncWrite(_ operation: @escaping () -> Void) async -> Bool {
        
        let realm = await getRealm()
        
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
