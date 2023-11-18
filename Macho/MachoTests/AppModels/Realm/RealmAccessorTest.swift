//
//  RealmAccessorTest.swift
//  MachoTests
//
//  Created by 佐藤汰一 on 2023/11/18.
//

import XCTest
@testable import Macho

final class RealmAccessorTest: XCTestCase {
    
    private let realmTestData = [DiarySearchTagEntity(id: UUID(), tagName: "testData1"),
                                 DiarySearchTagEntity(id: UUID(), tagName: "testData2")]
    
    override func setUp() async throws {
        
        try await super.setUp()
        
        await insertTestData()
    }
    
    override func tearDown() async throws {
        
        if await RealmAccessor().deleteAll() {
            
            print("Did end realm test case")
        }
        
        try await super.tearDown()
    }

    func testReadWithFilter() async throws {
        
        let realm = await RealmAccessor()
        
        guard let result = await realm.read(type: DiarySearchTagEntity.self, where: { $0.tagName.equals("testData1") }).first else {
            
            XCTFail("Fail read test Data")
            return
        }
        
        let expectedData = realmTestData.first!
        assert(expectedData.id == result.id)
        assert(expectedData.tagName == result.tagName)
    }
    
    func testReadAll() async throws {
        
        let realm = await RealmAccessor()
        
        let result = await realm.read(type: DiarySearchTagEntity.self)
        result.enumerated().forEach { index, resultEntity in
            
            assert(realmTestData[index].id == resultEntity.id)
        }
    }
    
    func testUpdate() async throws {
        
        let realm = await RealmAccessor()
        let targetID = realmTestData.first!.id
        let expectedData = DiarySearchTagEntity(id: targetID, tagName: "testData3")
        
        let updateValue = ["id": targetID, "tagName": expectedData.tagName] as [String : Any]
        guard await realm.update(type: DiarySearchTagEntity.self, value: updateValue),
              let result = await realm.read(type: DiarySearchTagEntity.self, where: { $0.id.in([targetID]) }).first else {
           
            XCTFail("Fail update")
            return
        }
        
        assert(result.id == expectedData.id)
        assert(result.tagName == expectedData.tagName)
    }
    
    func testDelete() async throws {
        
        let realm = await RealmAccessor()
        guard await realm.delete(type: DiarySearchTagEntity.self, where: { $0.id.in([realmTestData[0].id]) }) else {
            
            XCTFail("Fail delete")
            return
        }
        
        let results = await realm.read(type: DiarySearchTagEntity.self)
        let expectedData = realmTestData[1]
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first!.id , expectedData.id)
        XCTAssertEqual(results.first!.tagName, expectedData.tagName)
    }
}

private extension RealmAccessorTest {
    
    func insertTestData() async {
        
        let realm = await RealmAccessor()
        guard await realm.insert(records: realmTestData) else {
            
            XCTFail("Fail insert test Data")
            return
        }
    }
}
