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
        
        @ObservationStateIgnored var useCase = CreatingDiaryUseCase(initial: .initial)
        var titleText = ""
        var messageText = ""
        var tags: [Tag] = []
        var goals: [Goal] = []
        var animationsRunning = false
        var textFieldFocusState: DiaryCreationTextFieldFocus?
        var isEnableSaveButton: Bool { useCase.canSave }
        var isEnableFinishButton: Bool { useCase.canFinish }
        var shouldShowFinishButton: Bool { useCase.shouldShowFinishButton }
        var isEditMode: Bool { useCase.isEditMode }
        
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
        case trainingSaveButtonTapped
        case trainingFinishButtonTapped
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
    @Dependency(\.uuid) var uuid
    @Dependency(\.date) var date
    
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
                let tags = tags.map { TagConverter.toTag($0) }
                state = updateCreatingDiaryState(state.useCase.updateTags(tags),
                                                 state: state)
                return .none
                
            case .titleTextChange(let text):
                if state.titleText.isEmpty, text.isEmpty { return .none }
                state = updateCreatingDiaryState(state.useCase.editTitle(title: text), state: state)
                return .none
                
            case .messageTextChange(let text):
                state = updateCreatingDiaryState(state.useCase.editMainText(mainText: text), state: state)
                return .none
                
            case .trainingStartButtonTapped:
                return .concatenate(
                    .send(.animateStartButton),
                    .run { [state] _ in
                        
                        await saveDiary(diary: state.useCase.edited)
                    },
                    popToPrev()
                )
                
            case .trainingSaveButtonTapped:
                return .concatenate(
                    .send(.animateStartButton),
                    .run { [state] _ in
                        
                        await saveDiary(diary: state.useCase.edited)
                    },
                    popToPrev()
                )
                
            case .trainingFinishButtonTapped:
                return .concatenate(
                    .send(.animateStartButton),
                    .run { [state] _ in
                        
                        // TODO: トレーニングを終了状態に更新する
                        await saveDiary(diary: state.useCase.edited)
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
                    
                    state = updateCreatingDiaryState(state.useCase.selectTag(tag), state: state)
                }
                return .none
                
            case .longTappedTag(let tag):
                state.destination = .addTag(AddTagFeature.State(id: tag.id,
                                                                tagName: tag.tagName,
                                                                isEnableSaveButton: true))
                return .none
                
            case .tappedAddingGoalButton:
                state.destination = .addGoal(AddGoalFeature.State())
                return .none
                
            case .deletedGoal(let goal):
                withAnimation(.easeIn(duration: 0.5)) {
                    
                    state = updateCreatingDiaryState(state.useCase.removeGoal(goal), state: state)
                }
                return .none
                
            case .editingGoal(let goal):
                state.destination = .addGoal(AddGoalFeature.State(
                    id: goal.id,
                    selectedTrainingType: goal.trainingType,
                    numberOfSets: goal.numberOfSets,
                    setCount: goal.setCount,
                    isEnableSaveButton: true
                ))
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
                state = updateCreatingDiaryState(state.useCase.addGoal(goal), state: state)
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
    
    func saveDiary(diary: CreatingDiary?) async {
        
        guard let diary,
              let entity = convertToDbEntity(diary: diary) else { return }
        _ = await diaryListFetchApi.add(entity)
    }
    
    func convertToDbEntity(diary: CreatingDiary) -> DiaryData? {
        
        guard let title = diary.title,
              let mainText = diary.mainText else {
            
            assertionFailure("Unexpected empty diary data.")
            return nil
        }
        
        let id = diary.id ?? uuid()
        let createdAt = diary.createdAt ?? date()
        
        return .init(id: id,
                     date: createdAt,
                     title: title,
                     mainText: mainText,
                     goals: diary.goals.map(\.entity),
                     tags: diary.tags.filter(\.isSelected).map { TagConverter.toEntity($0) },
                     startTime: createdAt,
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
    
    func addObserveTagEntity() -> Effect<Self.Action> {
        
        return .publisher {
             
            return trainingTagApi.getTrainingTagPublisher()
                .receive(on: DispatchQueue.main)
                .map { .fetchedTags($0) }
        }.cancellable(id: TrainingTagsSubscriber())
    }
    
    func updateCreatingDiaryState(_ editEvent: CreatingDiaryUseCase.EditEvent, state: State) -> State {
        
        var updateState = state
        switch editEvent {
            
        case .title(let useCase):
            updateState.titleText = editEvent.currentDiary.title ?? ""
            updateState.useCase = useCase
            
        case .mainText(let useCase):
            updateState.messageText = editEvent.currentDiary.mainText ?? ""
            updateState.useCase = useCase
            
        case .tags(let useCase):
            updateState.tags = editEvent.currentDiary.tags
            updateState.useCase = useCase
            
        case .goals(let useCase):
            updateState.goals = editEvent.currentDiary.goals
            updateState.useCase = useCase
        }
        
        return updateState
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
        
        let goals: [Goal] = diary.goals.compactMap {
            
            guard let trainingType = $0.trainingType else {
                
                assertionFailure("Unexpected value: trainingType is nil.")
                return nil
            }
            return .init(id: $0.id,
                         trainingType: trainingType,
                         numberOfSets: $0.goalNumberOfSets,
                         setCount: $0.goalSetCount)
        }
        let tags: [Tag] = diary.tags.map { TagConverter.toTag($0, isSelected: true) }
        let creatingDiary = CreatingDiary(id: diary.id,
                                          createdAt: diary.date,
                                          title: diary.title,
                                          mainText: diary.mainText,
                                          goals: goals,
                                          tags: tags)
        
        useCase = .init(initial: creatingDiary)
        titleText = diary.title
        messageText = diary.mainText
        self.tags = tags
        self.goals = goals
    }
}
