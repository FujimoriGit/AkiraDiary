//
//  MachoFramework
//
//  RealmTestHelper.swift
//
//  Created by stotic-dev on 2025/02/28
//  Copyright © Macho All rights reserved.
//

import MachoCore
import RealmHelper
import XCTest

enum RealmTestHelper {
    
    static func getMockRealm() async throws -> RealmWrapper {
        
        return try await RealmFactory.create(config: .init(
            url: nil,
            version: 1,
            isOnMemoryId: UUID().uuidString
        ))
        .value
    }
    
    static func setupDiaryFilterList(_ client: DiaryListFilterClient,
                              filterList: [DiaryListFilterData]) async {
        
        for filter in filterList {
            
            let result = await client.addFilter(filter)
            XCTAssertTrue(result)
        }
    }
    
    static func setupDiaryDataList(_ client: DiaryEntityClient, diaryList: [DiaryData]) async {
        
        for diary in diaryList {
            
            let result = await client.add(diary)
            XCTAssertTrue(result)
        }
    }
    
    static func setupTrainingTypeList(_ client: TrainingTypeClient, typeList: [TrainingTypeData]) async {
        
        for type in typeList {
            
            let result = await client.add(type)
            XCTAssertTrue(result)
        }
    }
}
