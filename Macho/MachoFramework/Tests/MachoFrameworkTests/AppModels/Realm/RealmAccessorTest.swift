//
//  RealmAccessorTest.swift
//  MachoTests
//
//  Created by 佐藤汰一 on 2023/11/18.
//

import XCTest
@testable import RealmHelper

final class RealmAccessorTest: XCTestCase {
    
    private let realmTestData = [TrainingTagEntity(id: UUID(), tagName: "testData1"),
                                 TrainingTagEntity(id: UUID(), tagName: "testData2")]
    
    override func setUp() async throws {
        
        if await RealmAccessor().deleteAll() {
            
            print("Did init realmDB")
        }
        
        try await super.setUp()
        
        await insertTestData()
    }
    
    override func tearDown() async throws {
        
        if await RealmAccessor().deleteAll() {
            
            print("Did end realm test case")
        }
        
        try await super.tearDown()
    }
    
    override func tearDownWithError() throws {
        
        Task {
          
            if await RealmAccessor().deleteAll() {
                
                print("Did end realm test case")
            }
            
            try super.tearDownWithError()
        }
    }

    func testReadWithFilter() async throws {
        
        let realm = await RealmAccessor()
        
        guard let result: TrainingTagEntity = await realm.read(where: { $0.tagName == "testData1" }).first else {
            
            XCTFail("Fail read test Data")
            return
        }
        
        let expectedData = realmTestData.first!
        assert(expectedData.id == result.id)
        assert(expectedData.tagName == result.tagName)
    }
    
    func testReadAll() async throws {
        
        let realm = await RealmAccessor()
        
        let result: [TrainingTagEntity] = await realm.read()
        result.enumerated().forEach { index, resultEntity in
            
            assert(realmTestData[index].id == resultEntity.id)
        }
    }
    
    func testUpdate() async throws {
        
        let realm = await RealmAccessor()
        let targetID = realmTestData.first!.id
        let expectedData = TrainingTagEntity(id: targetID, tagName: "testData3")
        
        let updateValue = ["id": targetID, "tagName": expectedData.tagName] as [String : Any]
        await updateTestData(value: updateValue)
        
        guard let result: TrainingTagEntity = await realm.read(where: { $0.id == expectedData.id }).first else {
            
            XCTFail("Fail read")
            return
        }
        
        assert(result.id == expectedData.id)
        assert(result.tagName == expectedData.tagName)
    }
    
    func testDelete() async throws {
        
        let realm = await RealmAccessor()
        let filterId = realmTestData[0].id
        
        guard await realm.delete(where: { (tag: TrainingTagEntity) in tag.id == filterId }) else {
            
            XCTFail("Fail delete")
            return
        }
        
        let results: [TrainingTagEntity] = await realm.read()
        let expectedData = realmTestData[1]
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first!.id , expectedData.id)
        XCTAssertEqual(results.first!.tagName, expectedData.tagName)
    }
    
    func testObserveInsert() async throws {
        
        let expectation = self.expectation(description: "observeRealm")
        expectation.expectedFulfillmentCount = 1
        
        let expectedData = TrainingTagEntity(id: UUID(), tagName: "testData3")
        
        var results = [TrainingTagEntity]()
        let cancellable = TrainingTagEntity.executor.getPublisher()
            .sink { result in
                
                print("current result: \(result)")
                
                if result.count == 3 {
                    
                    results = result
                    expectation.fulfill()
                }
            }
        
        TrainingTagEntity.executor.startObservation()
        await insertTestData(data: [expectedData])
        
        // fulfillを待つ
        await fulfillment(of: [expectation], timeout: 10)
        cancellable.cancel()
        
        // Assertion開始
        guard let target = results.filter({ $0.id == expectedData.id }).first else {
            
            XCTFail("Fail observe, expectedId: \(expectedData.id)")
            return
        }
        
        XCTAssertEqual(target.id , expectedData.id)
        XCTAssertEqual(target.tagName, expectedData.tagName)
    }
    
    func testObserveUpdate() async throws {
        
        let expectation = self.expectation(description: "observeRealm")
        expectation.expectedFulfillmentCount = 1
        
        let expectedData = TrainingTagEntity(id: UUID(), tagName: "testData99")
        
        var results = [TrainingTagEntity]()
        let cancellable = TrainingTagEntity.executor.getPublisher()
            .sink { result in
                
                print("current result: \(result)")
                
                if result.count == 3 && result.contains(where: { $0.tagName == expectedData.tagName }) {
                    
                    results = result
                    expectation.fulfill()
                }
            }
        
        TrainingTagEntity.executor.startObservation()
        
        await insertTestData(data: [TrainingTagEntity(id: expectedData.id, tagName: "testData3")])
        let updateValue = ["id": expectedData.id, "tagName": expectedData.tagName] as [String : Any]
        await updateTestData(value: updateValue)
        
        // fulfillを待つ
        await fulfillment(of: [expectation], timeout: 10)
        cancellable.cancel()
        
        // Assertiton開始
        guard let target = results.filter({ $0.id == expectedData.id }).first else {
            
            XCTFail("Fail observe, expectedId: \(expectedData.id)")
            return
        }
        
        XCTAssertEqual(target.id , expectedData.id)
        XCTAssertEqual(target.tagName, expectedData.tagName)
    }
    
    func testObserveDelete() async throws {
        
        let expectation = self.expectation(description: "observeRealm")
        expectation.expectedFulfillmentCount = 1
        
        let deleteTarget = realmTestData[0]
        
        var results = [TrainingTagEntity]()
        let cancellable = TrainingTagEntity.executor.getPublisher()
            .sink { result in
                
                print("current result: \(result)")
                
                if result.count == 1 {
                    
                    results = result
                    expectation.fulfill()
                }
            }
        
        TrainingTagEntity.executor.startObservation()
        await deleteTestData(deleteTarget: deleteTarget.id)
        
        // fulfillを待つ
        await fulfillment(of: [expectation], timeout: 10)
        cancellable.cancel()
        
        // Assertiton開始
        if results.contains(where: { $0.id == deleteTarget.id }) {
            
            XCTFail("Fail delete")
        }
    }
}

private extension RealmAccessorTest {
    
    func insertTestData(data: [TrainingTagEntity] = []) async {
        
        let realm = await RealmAccessor()
        guard await realm.insert(records: data.isEmpty ? realmTestData : data) else {
            
            XCTFail("Fail insert test Data")
            return
        }
    }
    
    func updateTestData(value: [String: Any]) async {
        
        let realm = await RealmAccessor()
        guard await realm.update(type: TrainingTagEntity.self, value: value) else {
           
            XCTFail("Fail update")
            return
        }
    }
    
    func deleteTestData(deleteTarget: UUID) async {
        
        let realm = await RealmAccessor()
        guard await realm.delete(where: { (entity: TrainingTagEntity) in
            
            return entity.id == deleteTarget
        }) else {
            
            XCTFail("Fail delete")
            return
        }
    }
}
