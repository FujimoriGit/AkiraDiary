//
//  DiaryCreationFeature.swift
//  Macho
//  
//  Created by Daiki Fujimori on 2024/01/07
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct DiaryCreationFeature: Sendable {
    
    struct TrainingTagsSubscriber: Hashable {}
    
    // MARK: State
    
    @ObservableState
    struct State: Equatable {
        
        var titleText = ""
        var messageText = ""
        var tags: [Tag] = []
        var goals: [Goal] = []
        var isEnableStartButton = false
        var animationsRunning = false
        var textFieldFocusState: DiaryCreationTextFieldFocus?
        
        @Presents var destination: Destination.State?
        @Presents var alert: AlertState<Action.Alert>?
    }
    
    // MARK: - Action
    
    enum Action: Sendable, Equatable {
        
        case onAppear
        case didChangeTags
        case fetchedTags([TrainingTagData])
        case titleTextChange(String)
        case messageTextChange(String)
        case trainingStartButtonTapped
        case animateStartButton
        case destination(PresentationAction<Destination.Action>)
        case tappedAddingTagButton
        case tappedTag(Tag)
        case longTappedTag(Tag)
        case tappedAddingGoalButton
        case deletedGoal(Goal)
        case editingGoal(Goal)
        case didChangeFocusState(DiaryCreationTextFieldFocus?)
        case tappedOutsideOfKeyboard
        case tappedNavigationBackButton
        case alert(PresentationAction<Alert>)
    }
    
    @Dependency(\.trainingTagApi) var trainingTagApi
    @Dependency(\.diaryListFetchApi) var diaryListFetchApi
    @Dependency(\.dismiss) var dismiss
    
    // MARK: - body
    
    var body: some ReducerOf<Self> {
        
        // swiftlint:disable:next closure_body_length
        Reduce { state, action in
            
            switch action {
                
            case .onAppear:
                logger.debug("onAppear")
                return .concatenate(
                    addObserveTagEntity(),
                    fetchTags()
                )
                
            case .didChangeTags:
                return fetchTags()
                
            case .fetchedTags(let tags):
                state.tags = tags.map { entity in
                    
                    if let tag = state.tags.first(where: { $0.id == entity.id }) {
                        
                        return Tag(entity: entity, isSelected: tag.isSelected)
                    }
                    
                    return Tag(entity: entity)
                }
                return .none
                
            case .titleTextChange(let text):
                if state.titleText.isEmpty, text.isEmpty { return .none }
                state.titleText = text
                state.isEnableStartButton = isEnableStartButton(state: state)
                return .none
                
            case .messageTextChange(let text):
                state.messageText = text
                return .none
                
            case .trainingStartButtonTapped:
                return .concatenate(
                    .send(.animateStartButton),
                    .run { [state] _ in
                        
                        await addDiary(state: state)
                    },
                    popToPrev()
                )
                
            case .animateStartButton:
                withAnimation(.easeIn(duration: 0.5)) {
                    
                    state.animationsRunning.toggle()
                }
                return .none
                
            case .tappedAddingTagButton:
                state.destination = .addTag(AddTagFeature.State())
                return .none
                
            case .tappedTag(let tag):
                withAnimation(.easeIn(duration: 0.15)) {
                    
                    state.tags = updateTagSelectedState(target: tag, currentList: state.tags)
                }
                return .none
                
            case .longTappedTag(let tag):
                state.destination = .addTag(AddTagFeature.State(id: tag.id,
                                                                tagName: tag.entity.tagName,
                                                                isEnableSaveButton: true))
                return .none
                
            case .tappedAddingGoalButton:
                state.destination = .addGoal(AddGoalFeature.State())
                return .none
                
            case .deletedGoal(let goal):
                withAnimation(.easeIn(duration: 0.5)) {
                    
                    state.goals.removeAll(where: { $0.id == goal.id })
                    state.isEnableStartButton = isEnableStartButton(state: state)
                }
                return .none
                
            case .editingGoal(let goal):
                state.destination = .addGoal(AddGoalFeature.State(selectedTrainingType: goal.trainingType,
                                                                  numberOfSets: goal.numberOfSets,
                                                                  setCount: goal.setCount,
                                                                  isEnableSaveButton: true))
                return .none
                
            case .didChangeFocusState(let newState):
                state.textFieldFocusState = newState
                return .none
                
            case .tappedOutsideOfKeyboard:
                state.textFieldFocusState = nil
                return .none
                
            case .tappedNavigationBackButton:
                state.alert = .createAlertStateWithCancel(.confirmNoSavingDiary,
                                                          firstButtonHandler: .tappedDismissAcceptButton)
                return .none
                
            case .destination(.presented(.addGoal(.delegate(.saveGoal(let goal))))):
                guard let index = state.goals.firstIndex(where: { $0.trainingType == goal.trainingType }) else {
                    
                    state.goals.append(goal)
                    state.isEnableStartButton = isEnableStartButton(state: state)
                    return .none
                }
                state.goals[index] = goal
                state.isEnableStartButton = isEnableStartButton(state: state)
                return .none
                
            case .alert(.presented(.tappedDismissAcceptButton)):
                return popToPrev()
                
            case .destination, .alert:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .ifLet(\.$alert, action: \.alert)
    }
}

// MARK: - private method

private extension DiaryCreationFeature {
    
    func fetchTags() -> Effect<Self.Action> {
        
        return .run { send in
            
            let tags = await trainingTagApi.fetchAll()
            
            await send(.fetchedTags(tags))
        }
    }
    
    func addDiary(state: State) async {
        
        let diary = createDiary(state: state)
        _ = await diaryListFetchApi.add(diary)
    }
    
    func createDiary(state: State) -> DiaryData {
        
        let startDate = Date()
        
        let goals = state.goals.map {
            
            TrainingContentData(id: $0.id,
                                trainingType: $0.trainingType,
                                goalNumberOfSets: $0.numberOfSets,
                                goalSetCount: $0.setCount,
                                actualNumberOfSets: nil,
                                actualSetCount: nil)
        }
        
        let tags = state.tags.map(\.entity)
        
        return DiaryData(id: UUID(),
                         date: startDate,
                         title: state.titleText,
                         mainText: state.messageText,
                         goals: goals,
                         tags: tags,
                         startTime: startDate,
                         endTime: nil)
    }
    
    func popToPrev() -> Effect<Self.Action> {
        
        return .merge(
            .cancel(id: TrainingTagsSubscriber()),
            .run { _ in
                
                await dismiss()
            }
        )
    }
    
    func isEnableStartButton(state: State) -> Bool {
        
        return !(state.titleText.isEmpty || state.goals.isEmpty)
    }
    
    func addObserveTagEntity() -> Effect<Self.Action> {
        
        return .publisher {
             
            return trainingTagApi.getTrainingTagPublisher()
                .receive(on: DispatchQueue.main)
                .map { .fetchedTags($0) }
        }.cancellable(id: TrainingTagsSubscriber())
    }
    
    func updateTagSelectedState(target: Tag, currentList: [Tag]) -> [Tag] {
        
        guard let targetIndex = currentList.firstIndex(where: { $0 == target }) else {
            
            return currentList
        }
        
        var result = currentList
        let currentTag = result[targetIndex]
        result[targetIndex] = .init(entity: target.entity,
                                    isSelected: !currentTag.isSelected)
        return result
    }
}

// MARK: - extension (for destination)

extension DiaryCreationFeature {
    
    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        
        case addTag(AddTagFeature)
        case addGoal(AddGoalFeature)
    }
}

// MARK: - extension (for alert)

extension DiaryCreationFeature.Action {
    
    enum Alert {
        
        /// 前画面を戻ることを了承するボタンを押下
        case tappedDismissAcceptButton
    }
}

// MARK: - extension (for state)

extension DiaryCreationFeature.State {
    
    init(editTarget diary: DiaryData) {
        
        titleText = diary.title
        messageText = diary.mainText
        tags = diary.tags.map { .init(entity: $0, isSelected: true) }
        goals = diary.goals.compactMap {
            
            guard let trainingType = $0.trainingType else {
                
                assertionFailure("Unexpected value: trainingType is nil.")
                return nil
            }
            return .init(id: $0.id,
                         trainingType: trainingType,
                         numberOfSets: $0.goalNumberOfSets,
                         setCount: $0.goalSetCount)
        }
        
    }
}
