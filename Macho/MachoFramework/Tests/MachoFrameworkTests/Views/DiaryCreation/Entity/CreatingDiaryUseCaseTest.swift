//
//  MachoFramework
//
//  CreatingDiaryUseCaseTest.swift
//
//  Created by stotic-dev on 2025/03/16
//  Copyright © Macho All rights reserved.
//

import Foundation
import Testing

@testable import MachoView

@Suite("日記作成・編集のユースケーステスト")
struct CreatingDiaryUseCaseTest {
    
    @Suite("保存可能判定処理のケース")
    struct CanSaveCase {}
    
    @Suite("日記内容入力処理のケース")
    struct EditCase {}
}

extension CreatingDiaryUseCaseTest.CanSaveCase {
    
    @Test(arguments: [
        (CreatingDiary.make(id: nil, createdAt: nil), true),
        (CreatingDiary.make(id: nil, createdAt: nil, tags: []), true),
        (.make(id: nil, createdAt: nil, title: ""), false),
        (.make(id: nil, createdAt: nil, mainText: ""), false),
        (.make(id: nil, createdAt: nil, goals: []), false),
        (Optional(nilLiteral: ()), false),
    ])
    func タイトルと本文と目標が設定されており編集前と異なる内容の場合は保存可能となる(
        inputEditedDiary: CreatingDiary?,
        expected: Bool
    ) throws {
        
        let sut = CreatingDiaryUseCase(
            initial: CreatingDiary.make(),
            edited: inputEditedDiary
        )
        
        let result = sut.canSave
        
        #expect(result == expected)
    }
    
    @Test(arguments: [
        (CreatingDiary.make(), true),
        (CreatingDiary.make(mainText: "edited message"), true),
        (CreatingDiary.make(goals: [
            .init(id: UUID(), trainingType: .abs, numberOfSets: 3, setCount: 3)
        ]), true),
        (CreatingDiary.make(tags: [
            .init(id: CreatingDiary.defaultTag.id,
                  tagName: CreatingDiary.defaultTag.tagName,
                  isSelected: true)
        ]), true),
        (Optional(nilLiteral: ()), false),
        (CreatingDiary.make(title: ""), false),
        (CreatingDiary.make(mainText: ""), false),
        (CreatingDiary.make(goals: []), false)
    ])
    func 新規日記作成時にタイトルと本文と目標が設定されている場合は保存可能となる(
        inputEditedDiary: CreatingDiary?,
        expected: Bool
    ) throws {
        
        let sut = CreatingDiaryUseCase(
            initial: .initial,
            edited: inputEditedDiary
        )
        
        let result = sut.canSave
        
        #expect(result == expected)
    }
    
    @Test(arguments: [
        (CreatingDiary.make(), true),
        (CreatingDiary.make(mainText: "edited message"), true),
        (CreatingDiary.make(goals: [
            .init(id: UUID(), trainingType: .abs, numberOfSets: 3, setCount: 3)
        ]), true),
        (CreatingDiary.make(tags: [
            .init(id: CreatingDiary.defaultTag.id,
                  tagName: CreatingDiary.defaultTag.tagName,
                  isSelected: true)
        ]), true),
        (Optional(nilLiteral: ()), true),
        (CreatingDiary.make(title: ""), false),
        (CreatingDiary.make(mainText: ""), false),
        (CreatingDiary.make(goals: []), false)
    ])
    func タイトルと本文と目標が設定されている場合はトレーニング終了可能となる(
        inputEditedDiary: CreatingDiary?,
        expected: Bool
    ) throws {
        
        let sut = CreatingDiaryUseCase(
            initial: CreatingDiary.make(),
            edited: inputEditedDiary
        )
        
        let result = sut.canFinish
        
        #expect(result == expected)
    }
    
    @Test(arguments: [
        CreatingDiaryUseCase.init(initial: .make()),
        .init(initial: .make(), edited: .make(title: "edit")),
        .init(initial: .make(), edited: .make(title: "edit", isFinished: true))
    ])
    func 日記のトレーニングが終了していなければ終了ボタンを表示する(useCase: CreatingDiaryUseCase) throws {
                
        let result = useCase.shouldShowFinishButton
        
        #expect(result)
    }
    
    @Test(arguments: [
        CreatingDiaryUseCase.init(initial: .make(isFinished: true)),
        .init(initial: .make(isFinished: true), edited: .make(title: "edit")),
        .init(initial: .make(isFinished: true), edited: .make(title: "edit", isFinished: true)),
        .init(initial: .make(isFinished: true), edited: .make(title: "edit"))
    ])
    func 日記のトレーニングが終了している場合は終了ボタンは表示しない(useCase: CreatingDiaryUseCase) throws {
                
        let result = useCase.shouldShowFinishButton
        
        #expect(!result)
    }
}

extension CreatingDiaryUseCaseTest.EditCase {
    
    @Test
    func 編集前のタイトルと異なるタイトルが入力された場合は変更を受け付ける() throws {
        
        let initial = CreatingDiary.make()
        let sut = CreatingDiaryUseCase(initial: initial)
        
        let result = sut.editTitle(title: "test(edited)")
        
        let expected = CreatingDiary.make(title: "test(edited)")
        #expect(result == .title(.init(initial: initial, edited: expected)))
    }
    
    @Test
    func 編集前のタイトルと同じタイトルが入力された場合は変更を受け付けない() throws {
        
        let initial = CreatingDiary.make(title: "test")
        let sut = CreatingDiaryUseCase(initial: initial)
        
        let result = sut.editTitle(title: "test")
        #expect(result == .title(.init(initial: initial)))
    }
    
    @Test
    func 編集前のメッセージと異なるメッセージが入力された場合は変更を受け付ける() throws {
        
        let initial = CreatingDiary.make()
        let sut = CreatingDiaryUseCase(initial: initial)
        
        let result = sut.editMainText(mainText: "test message(edited)")
        
        let expected = CreatingDiary.make(mainText: "test message(edited)")
        #expect(result == .mainText(.init(initial: initial, edited: expected)))
    }
    
    @Test
    func 編集前のメッセージと同じメッセージが入力された場合は変更を受け付けない() throws {
        
        let initial = CreatingDiary.make(mainText: "test message")
        let sut = CreatingDiaryUseCase(initial: initial)
        
        let result = sut.editMainText(mainText: "test message")
        #expect(result == .mainText(.init(initial: initial)))
    }
    
    @Test
    func 新しい目標が入力された場合は変更を受け付ける() throws {
        
        let initialGoals: [Goal] = [
            .init(id: UUID(), trainingType: .abs, numberOfSets: 3, setCount: 3)
        ]
        let initial = CreatingDiary.make(goals: initialGoals)
        let sut = CreatingDiaryUseCase(initial: initial)
        
        let newGoal = Goal(id: UUID(), trainingType: .benchPress, numberOfSets: 3, setCount: 3)
        let result = sut.addGoal(newGoal)
        
        let expected = CreatingDiary.make(goals: initialGoals + [newGoal])
        #expect(result == .goals(.init(initial: initial, edited: expected)))
    }
    
    @Test
    func 編集前の目標と異なる目標が入力された場合は変更を受け付ける() throws {
        
        let initialGoals: [Goal] = [
            .init(id: UUID(), trainingType: .abs, numberOfSets: 3, setCount: 3)
        ]
        let initial = CreatingDiary.make(goals: initialGoals)
        let sut = CreatingDiaryUseCase(initial: initial)
        
        let result = sut.addGoal(.init(
            id: initialGoals[0].id,
            trainingType: .abs,
            numberOfSets: 3,
            setCount: 2
        ))
        
        let expected = CreatingDiary.make(goals: [
            .init(
                id: initialGoals[0].id,
                trainingType: .abs,
                numberOfSets: 3,
                setCount: 2
            )
         ])
        #expect(result == .goals(.init(initial: initial, edited: expected)))
    }
    
    @Test
    func 編集前の目標と同じ目標が入力された場合は変更を受け付けない() throws {
        
        let initialGoals: [Goal] = [
            .init(id: UUID(), trainingType: .abs, numberOfSets: 3, setCount: 3)
        ]
        let initial = CreatingDiary.make(goals: initialGoals)
        let sut = CreatingDiaryUseCase(initial: initial)
        
        let result = sut.addGoal(initialGoals[0])
        
        #expect(result == .goals(.init(initial: initial)))
    }
    
    @Test
    func タグを選択すると選択状態が切り替わる() throws {
        
        let initialTags: [MachoView.Tag] = [
            .init(id: UUID(), tagName: "test1", isSelected: true),
        ]
        let initial = CreatingDiary.make(tags: initialTags)
        let sut = CreatingDiaryUseCase(initial: initial)
        
        let result = sut.selectTag(initialTags[0])
        
        let expected = CreatingDiary.make(tags: [
            .init(id: initialTags[0].id,
                  tagName: initialTags[0].tagName,
                  isSelected: false)
        ])
        #expect(result == .tags(.init(initial: initial, edited: expected)))
    }
    
    @Test(arguments: [
        CreatingDiaryUseCase(initial: .make(tags: [.init(id: TrainingTagData.fine.id, tagName: "test", isSelected: true)])),
        CreatingDiaryUseCase(
            initial: .make(tags: [.init(id: TrainingTagData.fine.id, tagName: "test", isSelected: true)]),
            edited: .make(title: "edited title", tags: [.init(id: TrainingTagData.fine.id, tagName: "test", isSelected: true)])
        ),
    ])
    func タグの種類に更新があると日記作成時に選択できるタグの種類にも反映される(
        initialUseCase: CreatingDiaryUseCase
    ) throws {
        
        let sut = initialUseCase
        
        let updatedTags: [TrainingTagData] = [
            .init(id: TrainingTagData.fine.id, tagName: "test"),
            .unfine
        ]
        let result = sut.updateTags(updatedTags.map { TagConverter.toTag($0) })
        
        let expectedInitialDiary = CreatingDiary.make(tags: [
            .init(id: TrainingTagData.fine.id, tagName: "test", isSelected: true),
            TagConverter.toTag(.unfine)
        ])
        let expectedEditedDiary: CreatingDiary? = if let edited = initialUseCase.edited {
            
            CreatingDiary.make(title: edited.title ?? "",
                               tags: expectedInitialDiary.tags)
        }
        else {
            
            nil
        }
        
        let expectedUseCase = CreatingDiaryUseCase(
            initial: expectedInitialDiary,
            edited: expectedEditedDiary
        )
        #expect(result == .tags(expectedUseCase))
    }
}

fileprivate extension CreatingDiary {
    
    static let defaultDiaryId = UUID()
    static let defaultDate = Date.create(year: 2025, month: 1, day: 1)
    static let defaultGoal = Goal(id: UUID(),
                                  trainingType: .abs,
                                  numberOfSets: 3,
                                  setCount: 3)
    static let defaultTag = MachoView.Tag(id: UUID(),
                                          tagName: "test",
                                          isSelected: false)
    
    static func make(id: UUID? = Self.defaultDiaryId,
                     createdAt: Date? = Self.defaultDate,
                     title: String = "test",
                     mainText: String = "test message",
                     goals: [Goal] = [defaultGoal],
                     tags: [MachoView.Tag] = [defaultTag],
                     isFinished: Bool = false) -> Self {
           
           
           return .init(
               id: id,
               createdAt: createdAt,
               title: title,
               mainText: mainText,
               goals: goals,
               tags: tags,
               isFinished: isFinished
           )
       }
}
