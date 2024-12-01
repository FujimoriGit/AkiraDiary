//
//  MockDiaryEntityClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

import Combine
import MachoCore
import XCTest

extension DiaryEntityClient {
    
    static func getMockClient(expectedFetchList: [ConcreteDiaryData] = [],
                              expectedDeleteDiaryId: UUID? = nil,
                              expectedDeleteDiaryResult: Bool = false,
                              stubObserver: AnyPublisher<[any DiaryData], Error> = PassthroughSubject().eraseToAnyPublisher()) -> DiaryEntityClient {
        
        return DiaryEntityClient {
            
            return expectedFetchList
        } deleteDiary: { targetId in
            
            guard let expectedDeleteDiaryId else {
                
                XCTFail("Failed to add filter.")
                return false
            }
            
            XCTAssertEqual(targetId, expectedDeleteDiaryId)
            return expectedDeleteDiaryResult
        } getDiaryObserver: {
            
            return stubObserver
        }
    }
}
