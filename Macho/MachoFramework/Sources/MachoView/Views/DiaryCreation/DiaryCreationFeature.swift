//
//  DiaryCreationFeature.swift
//  Macho
//  
//  Created by Daiki Fujimori on 2024/01/07
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

@Reducer
struct DiaryCreationFeature: Sendable {
    
    struct TrainingTagsSubscriber: Hashable {}
    struct TrainingGoalsSubscriber: Hashable {}
    
    // MARK: State
    
    @ObservableState
    struct State: Equatable {
        
        var titleText = ""
        var messageText = ""
        var tags: [Tag] = []
        var goals: [Goal] = []
        var isEnableStartButton = false
        var animationsRunning = false
        
        @Presents var destination: Destination.State?
    }
    
    // MARK: - Action
    
    enum Action: Sendable, Equatable {
        
        case onAppear
        case didChangeTags
        case didChangeGoals
        case fetchedTags([Tag])
        case fetchedGoals([Goal])
        case titleTextChange(String)
        case messageTextChange(String)
        case trainingStartButtonTapped
        case destination(PresentationAction<Destination.Action>)
        case tappedAddingTagButton
        case tappedTag(Tag)
        case tappedAddingGoalButton
        case tappedGoal(Goal)
    }
    
    @Dependency(\.trainingTagApi) var trainingTagApi
    @Dependency(\.trainingGoalApi) var trainingGoalApi
    
    // MARK: - body
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            
            switch action {
                
            case .onAppear:
                logger.info("onAppear")
                return .concatenate(
                    .publisher {
                        
                        return trainingTagApi.getTrainingTagPublisher()
                            .receive(on: DispatchQueue.main)
                            .map { _ in .didChangeTags }
                    }.cancellable(id: TrainingTagsSubscriber()),
                    .publisher {
                        
                        return trainingGoalApi.getTrainingGoalPublisher()
                            .receive(on: DispatchQueue.main)
                            .map { _ in .didChangeGoals }
                    }.cancellable(id: TrainingGoalsSubscriber()),
                    fetchTags(),
                    fetchGoals()
                )
                
            case .didChangeTags:
                return fetchTags()
                
            case .didChangeGoals:
                return fetchGoals()
                
            case .fetchedTags(let tags):
                state.tags = tags
                return .none
                
            case .fetchedGoals(let goals):
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
                state.destination = .addTag(AddTagFeature.State())
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
                
            case .destination(.presented(.addTag(.setTagName))):
                return .none
                
            case .tappedAddingGoalButton:
                state.destination = .addGoal(AddGoalFeature.State(goal: Goal(id: UUID(),
                                                                             goalName: "",
                                                                             numberOfSets: 0,
                                                                             setCount: 0)))
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
        .ifLet(\.$destination, action: \.destination)
    }
}

// MARK: - private method

private extension DiaryCreationFeature {
    
    func fetchTags() -> Effect<Self.Action> {
        
        return .run { send in
            
            let tags = await trainingTagApi.fetchAll().map {
                
                Tag(id: $0.id, tagName: $0.tagName)
            }
            
            await send(.fetchedTags(tags))
        }
    }
    
    func fetchGoals() -> Effect<Self.Action> {
        
        return .run { send in
            
            let goals = await trainingGoalApi.fetchAll().map {
                
                Goal(id: $0.id, goalName: $0.goalType.name, numberOfSets: $0.numberOfSets, setCount: $0.setCount)
            }
            
            await send(.fetchedGoals(goals))
        }
    }
    
    func cancelChangesetObserve() -> Effect<Self.Action> {
        
        return .concatenate(
            .cancel(id: TrainingTagsSubscriber()),
            .cancel(id: TrainingGoalsSubscriber())
        )
    }
}

// MARK: - extension (for destination)

extension DiaryCreationFeature {
    
    @Reducer(state: .equatable, action: .equatable)
    enum Destination: Equatable {
        
        case addTag(AddTagFeature)
        case addGoal(AddGoalFeature)
        
        var id: Int {
            
            switch self {
                
            case .addTag:
                return 0
                
            case .addGoal:
                return 1
            }
        }
        
        static func == (lhs: DiaryCreationFeature.Destination, rhs: DiaryCreationFeature.Destination) -> Bool {
            
            return lhs.id == rhs.id
        }
    }
}
