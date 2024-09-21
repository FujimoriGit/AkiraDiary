//
//  DiaryCreationFeature.swift
//  Macho
//  
//  Created by Daiki Fujimori on 2024/01/07
//  
//

import ComposableArchitecture
import RealmHelper
import SwiftUI

struct Tag: Equatable, Identifiable {
    
    let id: UUID
    var tagName: String
    var isSelected = false
}

struct Goal: Equatable, Identifiable {
    
    let id: UUID
    var goalName: String
    var numberOfSets: Int
    var setCount: Int
    var isSelected = false
}

struct DiaryCreationFeature: Reducer {
    
    // MARK: State
    
    struct State: Equatable {
        
        var titleText = ""
        var messageText = ""
        var tags: [Tag] = []
        var goals: [Goal] = []
        var isEnableStartButton = false
        var animationsRunning = false
        
        @PresentationState var destination: Destination.State?
    }
    
    // MARK: - Action
    
    enum Action: Equatable {
        
        case onAppear
        case fetched(tags: [Tag], goals: [Goal])
        case titleTextChange(String)
        case messageTextChange(String)
        case trainingStartButtonTapped
        case destination(PresentationAction<Destination.Action>)
        case tappedAddingTagButton
        case tappedTag(Tag)
        case tappedAddingGoalButton
        case tappedGoal(Goal)
    }
    
    // MARK: - body
    
    @Dependency(\.realmFetch) var realmFetch
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            
            switch action {
                
            case .onAppear:
                return .run { send in
                    
                    let tags = try await realmFetch.fetchTrainingTag(TrainingTagEntity.self).map {
                        
                        Tag(id: $0.id, tagName: $0.tagName)
                    }
                    
                    let goals = try await realmFetch.fetchTrainingGoal(TrainingGoalEntity.self).map {
                        
                        Goal(id: $0.id, goalName: $0.goalName, numberOfSets: $0.numberOfSets, setCount: $0.setCount)
                    }
                    
                    await send(.fetched(tags: tags, goals: goals))
                }
                
            case .fetched(let tags, let goals):
                state.tags = tags
                state.goals = goals
                return .none
                
            case .titleTextChange(let text):
                state.titleText = text
                return .none
                
            case .messageTextChange(let text):
                state.messageText = text
                return .none
                
            case .trainingStartButtonTapped:
                withAnimation(.easeIn(duration: 0.5)) {
                    
                    state.animationsRunning.toggle()
                }
                return .none
                
            case .tappedAddingTagButton:
                state.destination = .addTag(AddTagFeature.State(tag: Tag(id: UUID(), tagName: "")))
                return .none
                
            case .destination(.presented(.addTag(.delegate(.saveTag(let tag))))):
                state.tags.append(tag)
                return .none
                
            case .tappedTag(let tag):
                withAnimation(.easeIn(duration: 0.5)) {
                    
                    state.tags = state.tags.map {
                        
                        if tag.id == $0.id {
                            
                            return Tag(id: $0.id, tagName: $0.tagName, isSelected: !$0.isSelected)
                        }
                        
                        return $0
                    }
                }
                return .none
                
            case .destination(.dismiss):
                return .none
                
            case .destination(.presented(.addTag(.cancelButtonTapped))):
                return .none
                
            case .destination(.presented(.addTag(.saveButtonTapped))):
                return .none
                
            case .destination(.presented(.addTag(.setTagName(_)))):
                return .none
                
            case .tappedAddingGoalButton:
                state.destination = .addGoal(AddGoalFeature.State(goal: Goal(id: UUID(), goalName: "", numberOfSets: 0, setCount: 0)))
                return .none
                
            case .tappedGoal(let goal):
                withAnimation(.easeIn(duration: 0.5)) {
                    
                    state.goals = state.goals.map {
                        
                        if goal.id == $0.id {
                            
                            return Goal(id: $0.id, goalName: $0.goalName, numberOfSets: $0.numberOfSets,
                                        setCount: $0.setCount, isSelected: !$0.isSelected)
                        }
                        
                        return $0
                    }
                }
                return .none
                
            case .destination(.presented(.addGoal(.cancelButtonTapped))):
                return .none
                
            case .destination(.presented(.addGoal(.saveButtonTapped))):
                return .none
                
            case .destination(.presented(.addGoal(.delegate(.saveTag(let goal))))):
                state.goals.append(goal)
                return .none
                
            case .destination(.presented(.addGoal(.setGoalName))):
                return .none
                
            case .destination(.presented(.addGoal(.setNumberOfSets))):
                return .none
                
            case .destination(.presented(.addGoal(.setCount))):
                return .none
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            
            Destination()
        }
    }
}

extension DiaryCreationFeature {
    
    struct Destination: Reducer {
        
        enum State: Equatable {
            
            case addTag(AddTagFeature.State)
            case addGoal(AddGoalFeature.State)
        }
        
        enum Action: Equatable {
            
            case addTag(AddTagFeature.Action)
            case addGoal(AddGoalFeature.Action)
        }
        
        var body: some ReducerOf<Self> {
            
            Scope(state: /State.addTag, action: /Action.addTag) {
                
                AddTagFeature()
            }
            
            Scope(state: /State.addGoal, action: /Action.addGoal) {
                
                AddGoalFeature()
            }
        }
    }
}
