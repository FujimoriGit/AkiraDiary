//
//  DiaryListFilterRepositoryTest.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/12/02.
//

@preconcurrency import Combine
import Foundation
import Testing

@testable import MachoCore
@testable import MachoModel
@testable import RealmHelper

@Suite(
    "日記リストフィルターEntityRepositoryTest",
    .timeLimit(.minutes(1))
)
@MainActor
struct DiaryListFilterRepositoryTest {
    
    @Test(
        "Entityの追加、取得、更新、削除ができることを確認する",
        arguments: [
            DiaryListFilterData(id: "test-uuid-1", filterTarget: "aaaaa", filterId: UUID(0), filterValue: "sjlefjilse"),
            DiaryListFilterData(id: "test-uuid-2",
                                        filterTarget: "aasjfisjeljaiefjsleifjlasijfljsiejflisefjlisaejfiajsifjsleifjlisejfjsaeifaaa",
                                        filterId: UUID(1),
                                        filterValue: "slfjiesjflsajlefjlsaijeflisajeflasjefaisejflasei")
        ]
    )
    func entityIoTest(updateFilter: DiaryListFilterData) async throws {
        
        let realm = TestRealmGenerator.setupRealm()
        let testRepository = DiaryListFilterEntityRepositoryImpl(realm: realm)
        
        let initialFilter = DiaryListFilterData(id: UUID().uuidString,
                                                        filterTarget: "trainingType",
                                                        filterId: UUID(),
                                                        filterValue: "腹筋")
        
        #expect(await testRepository.add(initialFilter), "check insert proc is successed.")
        
        let fetchResultAfterAdd = await testRepository.fetchAll()
        #expect([initialFilter] == fetchResultAfterAdd)
        
        let updateTargetFilter = DiaryListFilterData(id: initialFilter.id,
                                                        filterTarget: updateFilter.filterTarget,
                                                        filterId: updateFilter.filterId,
                                                        filterValue: updateFilter.filterValue)
        #expect(await testRepository.add(updateTargetFilter), "check update proc is successed.")
        
        let fetchResultAfterUpdate =  await testRepository.fetchAll()
        #expect([updateTargetFilter] == fetchResultAfterUpdate)
        
        #expect(await testRepository.deleteFilters([updateTargetFilter]), "check delete proc is successed.")
        
        let fetchResultAfterDelete = await testRepository.fetchAll()
        #expect([] == fetchResultAfterDelete)

        print("Complete DiaryListFilterRepositoryTest.entityIoTest")
    }
    
    static let entityArray = (1...10).map { _ in UUID() }
    
    @Test(
        "Entityの監視でEntityの追加、更新、削除を検知する挙動の確認",
        arguments: [
            ObserveTestArgument(insertIds: [await Self.entityArray[0]],
                                updateIds: [await Self.entityArray[0]],
                                deleteIds: [await Self.entityArray[0]]),
            ObserveTestArgument(insertIds: await Self.entityArray,
                                updateIds: [await Self.entityArray[0], await Self.entityArray[3]],
                                deleteIds: [await Self.entityArray[0], await Self.entityArray[7]])
        ]
    )
    func observeEntityTest(_ arg: ObserveTestArgument) async throws {
        
        let realm = TestRealmGenerator.setupRealm()
        let testRepository = DiaryListFilterEntityRepositoryImpl(realm: realm)
        var observeValues = await testRepository.getObserver()?.values.makeAsyncIterator()
        #expect(await observeValues?.next() == [],
                "check initial observe output is empty.")
        
        let insertEntities = arg.insertIds.map { DiaryListFilterData(id: $0.uuidString,
                                                                             filterTarget: "sample",
                                                                             filterId: $0,
                                                                             filterValue: "sample value") }
        
        let insertTask = Task {
            
            var expectedOutput: [DiaryListFilterData] = []
            
            for (index, expectedEntity) in insertEntities.enumerated() {
                
                expectedOutput.append(expectedEntity)
                
                let currentCount = index + 1
                print("Waiting insert event: \(currentCount) / \(insertEntities.count)")
                let output = await observeValues?.next() ?? []
                #expect(expectedOutput == output)
                print("Received insert event: \(currentCount) / \(insertEntities.count), output: \(output)")
            }
        }
        
        for insertEntity in insertEntities {
            
            #expect(await testRepository.add(insertEntity),
                    "check insert proc is successed.")
        }
        
        await insertTask.value
        
        let updateEntities: [DiaryListFilterData] = arg.updateIds.compactMap { updateId in
            
            guard let target = insertEntities.first(where: { $0.id == updateId.uuidString }) else { return nil }
            return DiaryListFilterData(id: target.id,
                                               filterTarget: "update target",
                                               filterId: target.filterId,
                                               filterValue: "update value")
        }
        
        let updateTask: Task<[DiaryListFilterData], Never> = Task {
            
            var expectedOutput = insertEntities
            for (index, updateEntity) in updateEntities.enumerated() {
                
                guard let updateIndex = expectedOutput
                    .firstIndex(where: { $0.id == updateEntity.id }) else {
                    
                    Issue.record("Not found update index(entity=\(updateEntity)).")
                    return []
                }
                
                expectedOutput[updateIndex] = updateEntity
                
                let currentCount = index + 1
                print("Waiting update event: \(currentCount) / \(updateEntities.count)")
                let updatedOutput = await observeValues?.next() ?? []
                #expect(expectedOutput == updatedOutput)
                print("Received update event: \(currentCount) / \(updateEntities.count), output: \(updatedOutput)")
            }
            
            return expectedOutput
        }
        
        for updateEntity in updateEntities {
            
            #expect(await testRepository.add(updateEntity),
                    "check update proc is successed.")
        }
        
        let currentEntities = await updateTask.value
        
        let deleteEntities: [DiaryListFilterData] = arg.deleteIds.compactMap { deleteId in
            
            guard let target = currentEntities.first(where: { $0.id == deleteId.uuidString }) else { return nil }
            return target
        }
        
        let deleteTask = Task {
            
            var expectedOutput = currentEntities
            for (index, deleteEntity) in deleteEntities.enumerated() {
                
                expectedOutput.removeAll { $0 == deleteEntity }
                
                let currentCount = index + 1
                print("Waiting delete event: \(currentCount) / \(deleteEntities.count)")
                let actualOutput = await observeValues?.next() ?? []
                #expect(expectedOutput == actualOutput)
                print("Received update event: \(currentCount) / \(deleteEntities.count), output: \(actualOutput)")
            }
        }
        
        for deleteEntity in deleteEntities {
            
            #expect(await testRepository.deleteFilters([deleteEntity]))
        }
        
        await deleteTask.value
        
        print("Complete DiaryListFilterRepositoryTest.observeEntityTest")
    }
}

extension DiaryListFilterRepositoryTest {
    
    struct ObserveTestArgument {
        
        let insertIds: [UUID]
        let updateIds: [UUID]
        let deleteIds: [UUID]
    }
}
