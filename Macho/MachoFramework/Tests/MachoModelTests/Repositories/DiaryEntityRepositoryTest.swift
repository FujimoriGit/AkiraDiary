//
//  DiaryEntityRepositoryTest.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/30.
//

import Combine
import Foundation
import Testing

@testable import MachoCore
@testable import MachoModel
@testable import RealmHelper

@Suite(
    "日記エンティティリポジトリのテスト",
    .timeLimit(.minutes(1))
)
struct DiaryEntityRepositoryTest {
    
    @Test("日記の登録",
          arguments: [
            ConcreteDiaryData(id: UUID(),
                              date: Date(),
                              title: "sample1",
                              mainText: "sample1",
                              goals: [
                                ConcreteTrainingContentData(id: UUID(),
                                                            trainingType: Self.sampleTrainingType1,
                                                            goalNumberOfSets: 3,
                                                            goalSetCount: 3,
                                                            actualNumberOfSets: 3,
                                                            actualSetCount: 3,
                                                            startTime: nil,
                                                            endTime: nil,
                                                            isAchieved: true)
                              ],
                              tags: [Self.sampleTag1])
          ]
    )
    func insert(_ diary: ConcreteDiaryData) async throws {
        
        let realm = setupRealm(diary.id.uuidString)
        let testRepository = DiaryEntityRepositoryImpl(realm)
        var publisherValues = await testRepository.getDiaryObserver()
        var cancellable: AnyCancellable?
        
        await confirmation { confimation in
            
            cancellable = publisherValues?.sink(receiveCompletion: {
                
                if case let .failure(error) = $0 {
                    
                    Issue.record("Unexpected receive completion: \($0).")
                }
            }, receiveValue: { output in
                
                #expect(output.count == 1, "assert inserted observer output count.")
                assertDiaryData(expected: diary, actual: output.first)
                confimation.confirm()
                cancellable?.cancel()
            })
            
            #expect(await testRepository.insertOrUpdate(diary), "assert insert proc is successed.")
        }
        
//        let nilResult = try await publisherValues?.next()
//        #expect(nilResult == nil, "assert initial observer.")
        
        
        
//        let insertedResult = try await publisherValues?.next()
//        #expect(insertedResult?.count == 1, "assert inserted observer output count.")
//        assertDiaryData(expected: diary, actual: insertedResult?.first)
        
    }
}

private extension DiaryEntityRepositoryTest {
    
    func setupRealm(_ caseName: String) -> Task<RealmAccessible, Error> {
        
//        let config = DbConfiguration(isOnMemoryId: caseName, version: 1)
        let config = DbConfiguration(url: URL.applicationSupportDirectory.appending(path: "\(caseName).realm"),
                                     version: 1)
        return RealmFactory.create(config: config)
    }
    
    func assertDiaryData(expected: ConcreteDiaryData, actual: DiaryEntity?) {
        
        let expectedData = DiaryEntity(expected)
        #expect(expectedData == actual)
    }
}

private extension DiaryEntityRepositoryTest {
    
    static let sampleTag1 = ConcreteTrainingTagData(id: UUID(), tagName: "sample1")
    static let sampleTag2 = ConcreteTrainingTagData(id: UUID(), tagName: "sample2")
    
    static let sampleTrainingType1 = ConcreteTrainingTypeData(id: UUID(), name: "sample1")
    static let sampleTrainingType2 = ConcreteTrainingTypeData(id: UUID(), name: "sample2")
}
