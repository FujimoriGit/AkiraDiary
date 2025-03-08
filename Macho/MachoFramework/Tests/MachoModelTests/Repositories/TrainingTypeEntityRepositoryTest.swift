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
        
        let realm = TestRealmGenerator.setupRealm()
        let testRepository = TrainingTypeEntityRepositoryImpl(realm)
        
        let initialType = TrainingTypeData(id: UUID(), name: typeName)
        
        #expect(await testRepository.insert(initialType), "check insert proc is successed.")
        
        let fetchResultBeforeInsert = await testRepository.fetchAll()
        #expect([initialType] == fetchResultBeforeInsert)
        
        #expect(await testRepository.delete(initialType.id), "check delete proc is successed.")
        
        let fetchResultBeforeDelete = await testRepository.fetchAll()
        #expect([] == fetchResultBeforeDelete)
        
        print("Complete TrainingTypeEntityRepositoryTest.entityIoTest")
    }
}
