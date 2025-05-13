//
//  MachoFramework
//
//  CreatingDiaryUseCase.swift
//
//  Created by stotic-dev on 2025/03/16
//  Copyright © Macho All rights reserved.
//

struct CreatingDiaryUseCase: Equatable {
    
    private let initial: CreatingDiary
    let edited: CreatingDiary?
    
    init(initial: CreatingDiary, edited: CreatingDiary? = nil) {
        
        self.initial = initial
        self.edited = edited
    }
    
    var isEditMode: Bool {
        
        return initial.isEditMode
    }
    
    var shouldShowFinishButton: Bool {
        
        return !initial.isFinished
    }
    
    var canSave: Bool {
        
        return edited?.canSave ?? false
    }
    
    var canFinish: Bool {
        
        return edited?.canFinish ?? initial.canFinish
    }
    
    var finishTarget: CreatingDiary {
        
        return edited ?? initial
    }
    
    func editTitle(title: String) -> EditEvent {
        
        return .title(edit(title: title))
    }
    
    func editMainText(mainText: String) -> EditEvent {
        
        return .mainText(edit(mainText: mainText))
    }
    
    func addGoal(_ goal: Goal) -> EditEvent {
        
        var updateGoals = edited?.goals ?? initial.goals
        guard let targetIndex = updateGoals.firstIndex(where: { $0.id == goal.id }) else {
            
            return .goals(edit(goals: updateGoals + [goal]))
        }
        
        updateGoals[targetIndex] = goal
        return .goals(edit(goals: updateGoals))
    }
    
    func removeGoal(_ goal: Goal) -> EditEvent {
        
        var targetGoals = edited?.goals ?? initial.goals
        guard let targetIndex = targetGoals.firstIndex(where: { $0.id == goal.id }) else {
            
            return .goals(edit())
        }
        
        targetGoals.remove(at: targetIndex)
        return .goals(edit(goals: targetGoals))
    }
    
    func incrementActualSetCount(of goal: Goal) -> EditEvent {
        
        let targetGoals = edited?.goals ?? initial.goals
        return .goals(edit(goals: getUpdateGoals(
            updatedGoal: goal.incrementSet(),
            current: targetGoals
        )))
    }
    
    func decrementActualSetCount(of goal: Goal) -> EditEvent {
        
        let targetGoals = edited?.goals ?? initial.goals
        return .goals(edit(goals: getUpdateGoals(
            updatedGoal: goal.decrementSet(),
            current: targetGoals
        )))
    }
    
    func selectTag(_ tag: SelectionTag) -> EditEvent {
        
        let updateTags = edited?.tags ?? initial.tags
        return .tags(edit(tags: updateTags.map {
            
            $0 == tag ? .init(id: $0.id, tagName: $0.tag.tagName, isSelected: !$0.isSelected) : $0
        }))
    }
    
    func updateTags(_ tags: [SelectionTag]) -> EditEvent {
        
        let initialUpdatedTags = tags.map { tag in
            
            guard let actualTag = initial.tags.first(where: { $0.id == tag.id }) else {
                
                return tag
            }
            
            return actualTag
        }
        let newInitial = initial.edit(tags: initialUpdatedTags)
        
        guard let edited else { return .tags(.init(initial: newInitial)) }
        
        let editedUpdatedTags = tags.map { tag in
            
            guard let actualTag = edited.tags.first(where: { $0.id == tag.id }) else {
                
                return tag
            }
            
            return actualTag
        }
        let newEdited = edited.edit(tags: editedUpdatedTags)
        return .tags(.init(initial: newInitial, edited: newEdited))
    }
}

extension CreatingDiaryUseCase {
    
    enum EditEvent: Equatable {
        
        case title(CreatingDiaryUseCase)
        case mainText(CreatingDiaryUseCase)
        case tags(CreatingDiaryUseCase)
        case goals(CreatingDiaryUseCase)
        
        var currentDiary: CreatingDiary {
            
            let useCase = switch self {
            case .title(let creatingDiaryUseCase):
                creatingDiaryUseCase
                
            case .mainText(let creatingDiaryUseCase):
                creatingDiaryUseCase
                
            case .tags(let creatingDiaryUseCase):
                creatingDiaryUseCase
                
            case .goals(let creatingDiaryUseCase):
                creatingDiaryUseCase
            }
            
            guard let edited = useCase.edited else {
                
                return useCase.initial
            }
            return edited
        }
    }
}

private extension CreatingDiaryUseCase {
    
    func edit(title: String? = nil,
              mainText: String? = nil,
              goals: [Goal]? = nil,
              tags: [SelectionTag]? = nil) -> Self {
        
        let edited = (edited ?? initial).edit(title: title,
                                              mainText: mainText,
                                              goals: goals,
                                              tags: tags)
        if initial != edited {
            
            return .init(initial: initial, edited: edited)
        }
        else {
            
            return .init(initial: initial, edited: nil)
        }
    }
    
    func getUpdateGoals(updatedGoal: Goal, current: [Goal]) -> [Goal] {
        
        var updatedGoals = current
        guard let targetIndex = updatedGoals.firstIndex(where: { $0.id == updatedGoal.id }) else {
            
            return current
        }
        
        updatedGoals[targetIndex] = updatedGoal
        return updatedGoals
    }
}
