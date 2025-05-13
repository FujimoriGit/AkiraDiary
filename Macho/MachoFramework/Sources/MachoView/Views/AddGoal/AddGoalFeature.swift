//
//  AddGoalFeature.swift
//
//  
//  Created by Daiki Fujimori on 2024/05/03
//

@preconcurrency import Combine
import ComposableArchitecture
import Foundation
import MachoCore

@Reducer
struct AddGoalFeature: Sendable {
    
    struct TrainingTypesSubscriber: Hashable {}
    
    // MARK: - State
    
    @ObservableState
    struct State: Sendable, Equatable {
        
        var id: UUID?
        var trainingTypes: [TrainingTypeData] = []
        var selectedTrainingType: TrainingTypeData?
        var typeNameBeingAdded: String?
        var numberOfSets = 0
        var setCount = 0
        var isEnableSaveButton = false
        
        @Presents var destination: Destination.State?
    }
    
    // MARK: - Action
    
    enum Action: Sendable, Equatable {
        
        case destination(PresentationAction<Destination.Action>)
        
        case onAppear
        case didChangeTrainingTypes
        case fetchedTrainingTypes([TrainingTypeData])
        case cancelButtonTapped
        case delegate(Delegate)
        case selectedTrainingType(TrainingTypeData)
        case saveButtonTapped
        case setNumberOfSets(Int)
        case setCount(Int)
        case addingTrainingType
        case observePublisher(PublisherEvent)
        
        @CasePathable
        enum PublisherEvent: Equatable {
            
            case observeTrainingType(AnyPublisher<[TrainingTypeData], Never>)
            
            static func == (lhs: AddGoalFeature.Action.PublisherEvent,
                            rhs: AddGoalFeature.Action.PublisherEvent) -> Bool {
                
                return lhs.is(\.observeTrainingType) == rhs.is(\.observeTrainingType)
            }
        }
        
        enum Delegate: Equatable {
            
            case saveGoal(Goal)
        }
    }
    
    // MARK: - Dependencies
    
    @Dependency(\.trainingTypeClient) var trainingTypeApi
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.uuid) var uuid
    
    // MARK: - body
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            
            switch action {
                
            case .onAppear:
                return .concatenate(
                    .run { send in
                        
                        guard let publisher = await trainingTypeApi.getObserve() else { return }
                        await send(.observePublisher(.observeTrainingType(publisher)))
                    },
                    fetchTrainingTypes()
                )
                
            case .didChangeTrainingTypes:
                return fetchTrainingTypes()
                
            case .fetchedTrainingTypes(let trainingTypes):
                state.trainingTypes = trainingTypes
                if let typeNameBeingAdded = state.typeNameBeingAdded,
                   let addedTrainingType = state.trainingTypes.first(where: { $0.name == typeNameBeingAdded }) {
                    
                    state.selectedTrainingType = addedTrainingType
                    state.typeNameBeingAdded = nil
                }
                return .none
                
            case .cancelButtonTapped:
                return .run { _ in await dismiss() }
                
            case .selectedTrainingType(let trainingType):
                state.selectedTrainingType = trainingType
                state.isEnableSaveButton = isEnableSaveButton(state: state)
                return .none
                
            case .saveButtonTapped:
                return .run { [state] send in
                    
                    guard let goalType = state.selectedTrainingType else { return }
                    
                    let goal = Goal(id: state.id ?? uuid(),
                                    trainingType: TrainingTypeConverter.toType(goalType),
                                    numberOfSets: state.numberOfSets,
                                    setCount: state.setCount)
                    
                    await send(.delegate(.saveGoal(goal)))
                    await dismiss()
                }
                
            case .setNumberOfSets(let numberOfSets):
                state.numberOfSets = numberOfSets
                state.isEnableSaveButton = isEnableSaveButton(state: state)
                return .none
                
            case .setCount(let setCount):
                state.setCount = setCount
                state.isEnableSaveButton = isEnableSaveButton(state: state)
                return .none
                
            case .addingTrainingType:
                state.destination = .addTrainingType(AddTrainingTypeFeature.State())
                return .none
                
            case .destination(.presented(.addTrainingType(.delegate(.addedTrainingType(let name))))):
                state.typeNameBeingAdded = name
                return .none
                
            case .destination:
                return .none
                
            case .observePublisher(.observeTrainingType(let publisher)):
                return .publisher {
                    
                    return publisher
                        .receive(on: DispatchQueue.main)
                        .map { .fetchedTrainingTypes($0) }
                }
                .cancellable(id: TrainingTypesSubscriber())
                
            case .delegate, .observePublisher:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension AddGoalFeature {
    
    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        
        case addTrainingType(AddTrainingTypeFeature)
    }
}

private extension AddGoalFeature {
    
    func isEnableSaveButton(state: State) -> Bool {
        
        return state.setCount > 0 && state.numberOfSets > 0 && state.selectedTrainingType != nil
    }
    
    func fetchTrainingTypes() -> Effect<Self.Action> {
        
        return .run { send in
            
            let trainingTypes = await trainingTypeApi.fetchAllType()
            await send(.fetchedTrainingTypes(trainingTypes))
        }
    }
}
