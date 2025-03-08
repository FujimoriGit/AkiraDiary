//
//  DiaryEntityRepositoryTest.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/30.
//

@preconcurrency import Combine
import Foundation
import Testing

@testable import MachoCore
@testable import MachoModel
@testable import RealmHelper

@Suite(
    "日記EntityRepositoryTest",
    .timeLimit(.minutes(1))
)
@MainActor
struct DiaryEntityRepositoryTest {
    
    static let dummyIdArray = (1...10).map { _ in UUID() }
    
    @Test(
        "日記取得処理と取得したエンティティの検証",
        arguments: [
            (1, 1, 2, 1),
            (1, 1, 1, 1),
            (1, 1, 1, 2),
            (1, 1, 0, 2),
            (1, 1, 1, 0),
            (1, 1, 0, 0),
            (99, 99, 99, 99),
        ]
    )
    func fetchEntityTest(goalSet: Int, goalNumOfSet: Int, actualSet: Int, actualNumOfSet: Int) async throws {
        
        let realm = TestRealmGenerator.setupRealm()
        let testRepository = DiaryEntityRepositoryImpl(realm)
        
        let entity = DiaryData(id: UUID(),
                                       date: Date(),
                                       title: "sample",
                                       mainText: "sample",
                                       goals: [
                                         TrainingContentData(id: UUID(),
                                                                     trainingType: Self.sampleTrainingType1,
                                                                     goalNumberOfSets: goalNumOfSet,
                                                                     goalSetCount: goalSet,
                                                                     actualNumberOfSets: actualNumOfSet,
                                                                     actualSetCount: actualSet,
                                                                     isAchieved: (actualNumOfSet >= goalNumOfSet && actualSet >= goalSet) || actualSet > goalSet)
                                       ],
                                       tags: [Self.sampleTag1],
                                       startTime: nil,
                                       endTime: nil)
        
        #expect(await testRepository.insertOrUpdate(entity),
                "assert insert proc is successed.")
        
        let result = await testRepository.fetchAll()
        #expect([entity] == result)
        
        print("Complete Test: case(\(#function)).")
    }
    
    @Test(
        "日記エンティティの監視処理テスト",
        arguments: [
            ObserveEntityTestArgument(insertIds: [await Self.dummyIdArray[0]],
                                      deleteTargetIds: [await Self.dummyIdArray[0]]),
            ObserveEntityTestArgument(insertIds: await Self.dummyIdArray,
                                      deleteTargetIds: [
                                        await Self.dummyIdArray[0],
                                        await Self.dummyIdArray[3],
                                        UUID()
                                      ])
        ]
    )
    func observeDiaryEntityTest(_ testArg: ObserveEntityTestArgument) async throws {
        
        let insertDiaries = testArg.insertIds.map {
            
            DiaryData(id: $0,
                              date: Date(),
                              title: "sample_\($0.uuidString)",
                              mainText: "sample_\($0.uuidString)",
                              goals: [
                                TrainingContentData(id: UUID(),
                                                            trainingType: Self.sampleTrainingType1,
                                                            goalNumberOfSets: 3,
                                                            goalSetCount: 3,
                                                            actualNumberOfSets: 3,
                                                            actualSetCount: 3,
                                                            isAchieved: true)
                              ],
                              tags: [Self.sampleTag1],
                              startTime: nil,
                              endTime: nil)
        }
        
        let realm = TestRealmGenerator.setupRealm()
        let testRepository = DiaryEntityRepositoryImpl(realm)
        
        var observeValues = await testRepository.getDiaryObserver()?.values.makeAsyncIterator()
        #expect(await observeValues?.next() == [])
        
        print("start Observe: \(String(describing: observeValues))")
        
        let insetTask = Task {
            
            var result: [[DiaryData]] = []
            
            for i in 1...insertDiaries.count {
                
                print("Waiting insert event: \(i) / \(insertDiaries.count)")
                let output = await observeValues?.next() ?? []
                result.append(output)
                print("Received insert event: \(i) / \(insertDiaries.count), output: \(output)")
            }
            return result
        }
        
        for insertDiary in insertDiaries {
            
            #expect(await testRepository.insertOrUpdate(insertDiary),
                    "assert insert proc is successed.")
        }
        
        let observedOutputs = await insetTask.value
        var expectedOutputs: [DiaryData] = []
        
        for index in insertDiaries.indices {
            
            expectedOutputs.append(insertDiaries[index])
            
            #expect(expectedOutputs == observedOutputs[index])
        }
        
        let expectedDeleteDiaries = testArg.deleteTargetIds.filter { deleteId in
            
            insertDiaries.contains { $0.id == deleteId }
        }
        
        let deleteTask = Task {
            
            var result: [[DiaryData]] = []
            for i in 1...expectedDeleteDiaries.count {
                
                print("Waiting delete event: \(i) / \(expectedDeleteDiaries.count)")
                let output = await observeValues?.next() ?? []
                result.append(output)
                print("Received delete event: \(i) / \(expectedDeleteDiaries.count), output: \(output)")
            }
            return result
        }
        
        for id in testArg.deleteTargetIds {
            
            var result = false
            if let target = expectedDeleteDiaries.first(where: { $0 == id }) {
                
                result = await testRepository.deleteDiary(target)
            }
            else {
                
                result = await testRepository.deleteDiary(UUID())
            }
            
            #expect(result, "assert delete proc is successed.")
        }
        
        var observedDeletedOutputs = await deleteTask.value
        var expectedDeletedOutputs: [DiaryData] = insertDiaries
        
        for deleteDiary in expectedDeleteDiaries {
            
            expectedDeletedOutputs.removeAll { $0.id == deleteDiary }
            #expect(expectedDeletedOutputs == observedDeletedOutputs.removeFirst())
        }
        
        #expect(observedDeletedOutputs.isEmpty, "check all delete diary in expected.")
        
        print("Complete Test case\(#function): \(String(describing: observeValues))")
    }
}

struct ObserveEntityTestArgument {
    
    let id = UUID()
    let insertIds: [UUID]
    let deleteTargetIds: [UUID]
}

private extension DiaryEntityRepositoryTest {
    
    static let sampleTag1 = TrainingTagData(id: UUID(), tagName: "sample1")
    static let sampleTag2 = TrainingTagData(id: UUID(), tagName: "sample2")
    
    static let sampleTrainingType1 = TrainingTypeData(id: UUID(), name: "sample1")
    static let sampleTrainingType2 = TrainingTypeData(id: UUID(), name: "sample2")
}
