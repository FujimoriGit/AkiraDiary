//
//  DiaryEntityRepositoryImpl.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/28.
//

@preconcurrency import Combine
import Foundation
import MachoCore
import RealmHelper

public struct DiaryEntityRepositoryImpl: RealmUseable, Sendable {
        
    let realm: Task<RealmWrapper, Error>
    
    public init(_ realm: Task<RealmWrapper, Error>) {
        
        self.realm = realm
    }
    
    public func fetchAll() async -> [DiaryData] {
        
        logger.debug("[In]")
        return await getRealm()?.read() ?? []
    }
    
    public func insertOrUpdate(_ diary: DiaryData) async -> Bool {
        
        logger.debug("[In] diary: \(diary)")
        return await getRealm()?.insert(records: [diary]) ?? false
    }
    
    public func deleteDiary(_ id: UUID) async -> Bool {
        
        logger.debug("[In] id: \(id)")
        return await getRealm()?
            .delete { (entity: DiaryData) in entity.id == id } ?? false
    }
    
    public func getDiaryObserver() async -> AnyPublisher<[DiaryData], Never>? {
        
        logger.debug("[In]")
        guard let realm = await getRealm() else { return nil }
        return await realm.readObjectsForObserve(type: DiaryData.self)
            .eraseToAnyPublisher()
    }
}
