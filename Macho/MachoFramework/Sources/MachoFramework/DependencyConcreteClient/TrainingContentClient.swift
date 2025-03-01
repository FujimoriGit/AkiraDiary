//
//  TrainingContentClient.swift
//  MachoFramework
//  
//  Created by Daiki Fujimori on 2024/11/02
//  

import Combine
import ComposableArchitecture
import MachoCore
import MachoModel
import RealmHelper

extension TrainingContentClient: DependencyKey {
    
    private static let repository = TrainingContentRepositoryImpl(RealmStore.shared.realm)
    
    public static var liveValue: TrainingContentClient {
        return .init {
            
            return await repository.insert($0)
        } updateGoal: {
            
            return await repository.insert($0)
        } fetchAll: {
            
            return await repository.fetchAll()
        } getTrainingGoalPublisher: {
            
            return await repository.getObserver()
        }
    }
}
