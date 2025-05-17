//
//  TrainingContentClient.swift
//  MachoFramework
//  
//  Created by Daiki Fujimori on 2024/11/02
//  

@preconcurrency import Combine
import Foundation
import MachoCore
import RealmHelper

extension TrainingContentClient {
    
    init(realm: Task<RealmWrapper, Never>) {
        
        self = TrainingContentClient {
            
            return await Self.insert(realm: realm, entity: $0)
        } updateGoal: {
            
            return await Self.insert(realm: realm, entity: $0)
        } fetchAll: {
            
            return await Self.fetchAll(realm: realm)
        } getTrainingGoalPublisher: {
            
            return await Self.getObserver(realm: realm)
        }
    }
        
    public static let concreteValue = TrainingContentClient(realm: RealmStore.shared.getRealm())
}

private extension TrainingContentClient {
    
    static func fetchAll(realm: Task<RealmWrapper, Never>) async -> [TrainingContentData] {
        
        return await realm.value.read()
    }
    
    static func insert(realm: Task<RealmWrapper, Never>, entity: TrainingContentData) async -> Bool {
        
        return await realm.value.insert(records: [entity])
    }
    
    static func delete(realm: Task<RealmWrapper, Never>, id: UUID) async -> Bool {
        
        return await realm.value
            .delete { (entity: TrainingContentData) in entity.id == id }
    }
    
    static func getObserver(realm: Task<RealmWrapper, Never>) async -> AnyPublisher<[TrainingContentData], Never>? {
        
        return await realm.value.readObjectsForObserve(type: TrainingContentData.self)
            .eraseToAnyPublisher()
    }
}
