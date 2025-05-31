//
//  AddTagFeature.swift
//
//  
//  Created by Daiki Fujimori on 2024/04/06
//  

import ComposableArchitecture
import Foundation
import MachoCore

@Reducer
struct AddTagFeature: Sendable {
    
    // MARK: - State
    
    @ObservableState
    struct State: Equatable {
        
        var id: UUID?
        var tagName = ""
        var isEnableSaveButton = false
    }
    
    // MARK: - Action
    
    enum Action: Sendable, Equatable {
        
        case cancelButtonTapped
        case saveButtonTapped
        case setTagName(String)
    }
    
    // MARK: - Dependencies
    
    @Dependency(\.trainingTagClient) var trainingTagApi
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.uuid) var uuid
    
    // MARK: - body
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        
        switch action {
            
        case .cancelButtonTapped:
            return .run { _ in await dismiss() }
            
        case .saveButtonTapped:
            return .run { [id = state.id, tagName = state.tagName] _ in
                
                if let id {
                    
                    await updateTag(id: id, tagName: tagName)
                }
                else {
                    
                    await saveTag(tagName: tagName)
                }
                
                await dismiss()
            }
            
        case .setTagName(let tagName):
            state.tagName = tagName
            state.isEnableSaveButton = !tagName.isEmpty
            return .none
        }
    }
}

// MARK: - private method

private extension AddTagFeature {
    
    func saveTag(tagName: String) async {
        
        let currentTagList = await trainingTagApi.fetchAll()
        if currentTagList.contains(where: { $0.tagName == tagName }) {
            
            logger.error("same name already added.")
            return
        }
        
        let entity = TrainingTagData(id: uuid(), tagName: tagName)
        _ = await trainingTagApi.add(entity)
    }
    
    func updateTag(id: UUID, tagName: String) async {
        
        let entity = TrainingTagData(id: id, tagName: tagName)
        _ = await trainingTagApi.update(entity)
    }
}
