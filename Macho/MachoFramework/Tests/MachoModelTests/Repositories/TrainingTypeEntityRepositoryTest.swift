//
//  TrainingTypeEntityRepositoryTest.swift
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
    "トレーニング種目EntityRepositoryTest",
    .timeLimit(.minutes(1))
)
struct TrainingTypeEntityRepositoryTest {

    @Test(
        "Entityの取得、登録、削除が行えることを確認",
        arguments: [
            "sample",
            "lsjeiaslejflseijflasjeflijselfjslijfisejflisfisefjlesifsa"
        ]
    )
    func entityIoTest(_ typeName: String) async throws {
        
        let realm = TestRealmGenerator.setupRealm("training_type_entity_io_test_realm_\(UUID().uuidString)")
        let testRepository = TrainingTypeEntityRepositoryImpl(realm)
        
        let initialType = ConcreteTrainingTypeData(id: UUID(), name: typeName)
        
        #expect(await testRepository.insert(initialType), "check insert proc is successed.")
        assertTag([initialType], await testRepository.fetchAll())
        
        #expect(await testRepository.delete(initialType.id), "check delete proc is successed.")
        assertTag([], await testRepository.fetchAll())
        
        print("Complete TrainingTypeEntityRepositoryTest.entityIoTest")
    }
}

private extension TrainingTypeEntityRepositoryTest {
    
    func assertTag(_ expected: [ConcreteTrainingTypeData], _ actual: [TrainingTypeEntity]) {
        
        #expect(expected.map { TrainingTypeEntity($0) } == actual)
    }
}
