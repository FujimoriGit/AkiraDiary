//
//  RealmAccessorMock.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/10/12.
//

import RealmHelper
import RealmSwift
import Combine
import XCTest

struct RealmAccessorMock<Entity>: RealmAccessible where Entity: BaseRealmEntity {
    
    private var fetchEntity: [Entity]
    private var expectedInsertResult: ([Entity]) -> Bool
    private var expectedUpdateResult: (Entity.Type, [String : Any]) -> Bool
    private var expectedDeleteResult: () -> Bool
    private var expectedDeleteAllResult: () -> Bool
    private var expectedTruncateResult: () -> Bool
    private var expectedNotificationToken: NotificationToken
    
    init(fetchEntity: [Entity] = [],
         expectedInsertResult: @escaping ([Entity]) -> Bool = { _ in true },
         expectedUpdateResult: @escaping (Entity.Type, [String : Any]) -> Bool = { _, _ in true },
         expectedDeleteResult: @escaping () -> Bool = { true },
         expectedDeleteAllResult: @escaping () -> Bool = { true },
         expectedTruncateResult: @escaping () -> Bool = { true },
         expectedNotificationToken: NotificationToken = .init()) {
        
        self.fetchEntity = fetchEntity
        self.expectedInsertResult = expectedInsertResult
        self.expectedUpdateResult = expectedUpdateResult
        self.expectedDeleteResult = expectedDeleteResult
        self.expectedDeleteAllResult = expectedDeleteAllResult
        self.expectedTruncateResult = expectedTruncateResult
        self.expectedNotificationToken = expectedNotificationToken
    }
    
    func read<T>(where filterHandler: ((T) -> Bool)?) async -> [T] where T : BaseRealmEntity {
        
        guard let entities = fetchEntity as? [T] else {
            
            XCTFail("Invalid type entities: \(fetchEntity)")
            return []
        }
        
        printDebugLog("fetchEntity: \(fetchEntity)")
        
        return entities
    }
    
    func insert<T>(records: [T]) async -> Bool where T : RealmHelper.BaseRealmEntity {
        
        guard let entities = records as? [Entity] else {
            
            XCTFail("Invalid type records: \(records)")
            return false
        }
        let result = expectedInsertResult(entities)
        printDebugLog("expectedInsertResult: \(result)")
        return result
    }
    
    func update<T>(type: T.Type, value: [String : Any]) async -> Bool where T : BaseRealmEntity {
        
        guard let type = type as? Entity.Type else {
            
            XCTFail("Invalid type: \(type)")
            return false
        }
        
        let result = expectedUpdateResult(type, value)
        printDebugLog("expectedUpdateResult: \(result)")
        return result
    }
    
    func delete<T>(where filterHandler: @escaping (T) -> Bool) async -> Bool where T : BaseRealmEntity {
        
        let result = expectedDeleteResult()
        printDebugLog("expectedDeleteResult: \(result)")
        return result
    }
    
    func deleteAll<T>(type: T.Type) async -> Bool where T : BaseRealmEntity {
        
        let result = expectedDeleteAllResult()
        printDebugLog("expectedDeleteAllResult: \(result)")
        return result
    }
    
    func truncateDb() async -> Bool {
        
        let result = expectedTruncateResult()
        printDebugLog("expectedTruncateResult: \(result)")
        return result
    }
    
    func observeDidChangeRealmObject<T>(subject: PassthroughSubject<[T], Never>) async -> NotificationToken? where T : BaseRealmEntity {
        
        printDebugLog("expectedNotificationToken: \(expectedNotificationToken)")
        return expectedNotificationToken
    }
}

private extension RealmAccessorMock {
    
    func printDebugLog(_ message: String,
                       file: String = #file,
                       function: String = #function,
                       line: Int = #line) {
        
        print("[\(file) \(function):\(line)] \(message)]")
    }
}
