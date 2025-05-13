//
//  DiaryCreationFeature.swift
//  Macho
//  
//  Created by Daiki Fujimori on 2024/01/07
//

@preconcurrency import Combine
import ComposableArchitecture
import MachoCore
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
        var tags: [SelectionTag] = []
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
        case tappedTag(SelectionTag)
        case longTappedTag(SelectionTag)
        case tappedAddingGoalButton
        case deletedGoal(Goal)
        case editingGoal(Goal)
        case tappedAddActualSetButton(Goal)
        case tappedMinusActualSetButton(Goal)
        case didChangeFocusState(DiaryCreationTextFieldFocus?)
        case tappedOutsideOfKeyboard
        case tappedNavigationBackButton
        case alert(PresentationAction<Alert>)
        case observePublisher(PublisherEvent)
        
        @CasePathable
        enum PublisherEvent: Equatable {
            
            case observeTags(AnyPublisher<[TrainingTagData], Never>)
            
            static func == (lhs: DiaryCreationFeature.Action.PublisherEvent,
                            rhs: DiaryCreationFeature.Action.PublisherEvent) -> Bool {
                
                return lhs.is(\.observeTags) == rhs.is(\.observeTags)
            }
        }
    }
    
    @Dependency(\.trainingTagClient) var trainingTagApi
    @Dependency(\.diaryEntityClient) var diaryListFetchApi
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
                return .run { send in
                    
                    guard let publisher = await trainingTagApi.getObserve() else { return }
                    await send(.observePublisher(.observeTags(publisher)))
                }
                
            case .didChangeTags:
                return fetchTags()
                
            case .fetchedTags(let tags):
                let tags = tags.map { SelectionTagConverter.toTag($0) }
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
                
            case .trainingStartButtonTapped, .trainingSaveButtonTapped:
                return saveEffect { [target = state.useCase.edited] in
                    
                    await saveDiary(diary: target)
                }
                
            case .trainingFinishButtonTapped:
                return saveEffect { [finishTarget = state.useCase.finishTarget] in
                    
                    await finishTraining(diary: finishTarget)
                }
                
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
                
            case .longTappedTag(let selectionTag):
                state.destination = .addTag(AddTagFeature.State(id: selectionTag.id,
                                                                tagName: selectionTag.tag.tagName,
                                                                isEnableSaveButton: true))
                return .none
                
            case .tappedAddingGoalButton:
                state.destination = .addGoal(AddGoalFeature.State())
                return .none
                
            case .deletedGoal(let goal):
                withAnimation(.easeIn(duration: 0.5)) {
                    
                    state = updateCreatingDiaryState(state.useCase.removeGoal(goal),
                                                     state: state)
                }
                return .none
                
            case .editingGoal(let goal):
                state.destination = .addGoal(AddGoalFeature.State(
                    id: goal.id,
                    selectedTrainingType: TrainingTypeConverter.toEntity(goal.trainingType),
                    numberOfSets: goal.numberOfSets,
                    setCount: goal.setCount,
                    isEnableSaveButton: true
                ))
                return .none
                
            case .tappedAddActualSetButton(let goal):
                state = updateCreatingDiaryState(
                    state.useCase.incrementActualSetCount(of: goal),
                    state: state
                )
                return .none
                
            case .tappedMinusActualSetButton(let goal):
                state = updateCreatingDiaryState(
                    state.useCase.decrementActualSetCount(of: goal),
                    state: state
                )
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
                
            case .observePublisher(.observeTags(let publisher)):
                return observeTag(publisher)
                
            case .destination(.presented(.addGoal(.delegate(.saveGoal(let goal))))):
                state = updateCreatingDiaryState(state.useCase.addGoal(goal), state: state)
                return .none
                
            case .alert(.presented(.tappedDismissAcceptButton)):
                return popToPrev()
                
            case .destination, .alert, .observePublisher:
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
    
    func saveEffect(saveAction: @Sendable @escaping () async -> Void) -> Effect<Self.Action> {
        
        return .concatenate(
            .send(.animateStartButton),
            .run { _ in await saveAction() },
            popToPrev()
        )
    }
    
    func saveDiary(diary: CreatingDiary?) async {
        
        guard let diary,
              let entity = convertToDbEntity(diary: diary) else { return }
        _ = await diaryListFetchApi.add(entity)
    }
    
    func finishTraining(diary: CreatingDiary?) async {
        
        guard let diary,
              let entity = convertToDbEntity(diary: diary.finish()) else { return }
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
                     goals: diary.goals.map { GoalConverter.toEntity($0) },
                     tags: diary.tags.filter(\.isSelected).map { SelectionTagConverter.toEntity($0) },
                     startTime: createdAt,
                     endTime: diary.isFinished ? date() : nil)
    }
    
    func popToPrev() -> Effect<Self.Action> {
        
        return .merge(
            .cancel(id: TrainingTagsSubscriber()),
            .run { _ in
                
                await dismiss()
            }
        )
    }
    
    func observeTag(_ publisher: AnyPublisher<[TrainingTagData], Never>) -> EffectOf<Self> {
        
        return .publisher {
            
            publisher
                .receive(on: DispatchQueue.main)
                .map { .fetchedTags($0) }
        }
        .cancellable(id: TrainingTagsSubscriber())
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
    
    init(editTarget diary: Diary) {
        
        let goals: [Goal] = diary.goals
        let tags: [SelectionTag] = diary.tags.map { .init(tag: $0, isSelected: true) }
        let creatingDiary = CreatingDiary(id: diary.id,
                                          createdAt: diary.createdAt,
                                          title: diary.title,
                                          mainText: diary.mainText,
                                          goals: goals,
                                          tags: tags,
                                          isFinished: diary.status != .training)
        
        useCase = .init(initial: creatingDiary)
        titleText = diary.title
        messageText = diary.mainText
        self.tags = tags
        self.goals = goals
    }
}
