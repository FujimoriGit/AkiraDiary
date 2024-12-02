//
//  TrainingTagEntityRepositoryTest.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/12/02.
//

import Foundation
import Testing

@testable import MachoCore
@testable import MachoModel
@testable import RealmHelper

@Suite(
    "タグEntityRepositoryTest",
    .timeLimit(.minutes(1))
)
struct TrainingTagEntityRepositoryTest {

    @Test(
        "Entityの取得、登録、削除が行えることを確認",
        arguments: [
            "sample",
            "lsjeiaslejflseijflasjeflijselfjslijfisejflisfisefjlesifsa"
        ]
    )
    func entityIoTest(_ tagName: String) async throws {
        
        let realm = TestRealmGenerator.setupRealm("training_tag_entity_io_test_realm_\(UUID().uuidString)")
        let testRepository = TrainingTagEntityRepositoryImpl(realm)
        
        let initialTag = ConcreteTrainingTagData(id: UUID(), tagName: tagName)
        
        #expect(await testRepository.insert(initialTag), "check insert proc is successed.")
        assertTag([initialTag], await testRepository.fetchAll())
        
        #expect(await testRepository.delete(initialTag.id), "check delete proc is successed.")
        assertTag([], await testRepository.fetchAll())
        
        print("Complete TrainingTagEntityRepositoryTest.entityIoTest")
    }
}

private extension TrainingTagEntityRepositoryTest {
    
    func assertTag(_ expected: [ConcreteTrainingTagData], _ actual: [TrainingTagEntity]) {
        
        #expect(expected.map { TrainingTagEntity($0) } == actual)
    }
}
