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
        
        let realm = TestRealmGenerator.setupRealm()
        let testRepository = TrainingTagEntityRepositoryImpl(realm)
        
        let initialTag = TrainingTagData(id: UUID(), tagName: tagName)
        
        #expect(await testRepository.insert(initialTag), "check insert proc is successed.")
        
        let fetchResultBeforeInsert = await testRepository.fetchAll()
        #expect([initialTag] == fetchResultBeforeInsert)
        
        #expect(await testRepository.delete(initialTag.id), "check delete proc is successed.")
        
        let fetchResultBeforeDelete = await testRepository.fetchAll()
        #expect([] == fetchResultBeforeDelete)
        
        print("Complete TrainingTagEntityRepositoryTest.entityIoTest")
    }
}
