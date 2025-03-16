//
//  MachoFramework
//
//  CreatingDiary.swift
//
//  Created by stotic-dev on 2025/03/16
//  Copyright © Macho All rights reserved.
//

import Foundation

struct CreatingDiaryUseCase: Equatable {
    
    private let initial: CreatingDiary
    let edited: CreatingDiary?
    
    init(initial: CreatingDiary) {
        
        self.initial = initial
        edited = nil
    }
    
    var isEditMode: Bool {
        
        return initial.isEditMode
    }
    
    var canSave: Bool {
        
        return edited?.canSave ?? false
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
        
        let targetGoals = edited?.goals ?? initial.goals
        guard let targetIndex = targetGoals.firstIndex(of: goal) else {
            
            return .goals(edit())
        }
        
        return .goals(edit(goals: targetGoals.dropFirst(targetIndex).map(\.self)))
    }
    
    func selectTag(_ tag: Tag) -> EditEvent {
        
        let updateTags = edited?.tags ?? initial.tags
        return .tags(edit(tags: updateTags.map {
            
            $0 == tag ? .init(id: $0.id, tagName: $0.tagName, isSelected: !$0.isSelected) : $0
        }))
    }
    
    func updateTags(_ tags: [Tag]) -> EditEvent {
        
        let newInitial = CreatingDiary(
            id: initial.id,
            createdAt: initial.createdAt,
            title: initial.title,
            mainText: initial.mainText,
            goals: initial.goals,
            tags: tags.map { tag in
                
                guard let actualTag = initial.tags.first(where: { $0.id == tag.id }) else {
                    
                    return tag
                }
                
                return actualTag
            }
        )
        
        guard let edited else { return .tags(.init(initial: newInitial)) }
        
        let newEdited = CreatingDiary(
            id: edited.id,
            createdAt: edited.createdAt,
            title: edited.title,
            mainText: edited.mainText,
            goals: edited.goals,
            tags: tags.map { tag in
                
                guard let actualTag = edited.tags.first(where: { $0.id == tag.id }) else {
                    
                    return tag
                }
                
                return actualTag
            }
        )
        
        return .tags(.init(initial: newInitial, edited: newEdited))
    }
}

extension CreatingDiaryUseCase {
    
    enum EditEvent {
        
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
    
    init(initial: CreatingDiary, edited: CreatingDiary?) {
        
        self.initial = initial
        self.edited = edited
    }
    
    private func edit(title: String? = nil,
                      mainText: String? = nil,
                      goals: [Goal]? = nil,
                      tags: [Tag]? = nil) -> Self {
        
        let edited = CreatingDiary(id: initial.id,
                                   createdAt: initial.createdAt,
                                   title: title ?? initial.title,
                                   mainText: mainText ?? initial.mainText,
                                   goals: goals ?? initial.goals,
                                   tags: tags ?? initial.tags)
        if initial != edited {
            
            return .init(initial: initial, edited: edited)
        }
        else {
            
            return .init(initial: initial, edited: nil)
        }
    }
}

struct CreatingDiary: Equatable {
    
    let id: UUID?
    let createdAt: Date?
    let title: String?
    let mainText: String?
    let goals: [Goal]
    let tags: [Tag]
            
    var canSave: Bool {
        
        if title?.isEmpty ?? true { return false }
        if mainText?.isEmpty ?? true { return false }
        if goals.isEmpty { return false }
        
        return true
    }
    
    var isEditMode: Bool {
        
        return id != nil && createdAt != nil && canSave
    }
}

extension CreatingDiary {
    
    static let initial: Self = .init(id: nil,
                                     createdAt: nil,
                                     title: nil,
                                     mainText: nil,
                                     goals: [],
                                     tags: [])
}
