//
//  TrainingContentClient.swift
//  MachoFramework
//  
//  Created by Daiki Fujimori on 2024/11/02
//  

@preconcurrency import Combine
import Foundation
import MachoCore

extension TrainingContentClient {
        
    public static var concreteValue: TrainingContentClient {
        return .init {
            
            return await insert($0)
        } updateGoal: {
            
            return await insert($0)
        } fetchAll: {
            
            return await fetchAll()
        } getTrainingGoalPublisher: {
            
            return await getObserver()
        }
    }
}

private extension TrainingContentClient {
    
    static func fetchAll() async -> [TrainingContentData] {
        
        return await RealmStore.shared.getRealm()?.read() ?? []
    }
    
    static func insert(_ entity: TrainingContentData) async -> Bool {
        
        return await RealmStore.shared.getRealm()?.insert(records: [entity]) ?? false
    }
    
    static func delete(_ id: UUID) async -> Bool {
        
        return await RealmStore.shared.getRealm()?
            .delete { (entity: TrainingContentData) in entity.id == id } ?? false
    }
    
    static func getObserver() async -> AnyPublisher<[TrainingContentData], Never>? {
        
        logger.debug("[In]")
        guard let realm = await RealmStore.shared.getRealm() else { return nil }
        return await realm.readObjectsForObserve(type: TrainingContentData.self)
            .eraseToAnyPublisher()
    }
}
