//
//  MockDiaryListFilterClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

@preconcurrency import Combine
import MachoCore
import XCTest

extension DiaryListFilterClient {
    
    static func getMockClient(expectedFetchList: [ConcreteDiaryListFilterData] = [],
                              expectedAddFilter: ConcreteDiaryListFilterData? = nil,
                              expectedAddFilterResult: Bool = false,
                              expectedDeleteFilters: [ConcreteDiaryListFilterData] = [],
                              expectedDeleteFiltersResult: Bool = false,
                              stubObserver: AnyPublisher<[any DiaryListFilterData], Never> = PassthroughSubject().eraseToAnyPublisher()) -> DiaryListFilterClient {
        
        return DiaryListFilterClient {
            
            return expectedFetchList
        } addFilter: { data in
            
            return await addFilterMock(expectedAddFilter: expectedAddFilter,
                                       expectedAddFilterResult: expectedAddFilterResult)(data)
        } deleteFilters: { targets in
            
            guard let targets = targets as? [ConcreteDiaryListFilterData] else {
                
                XCTFail("Failed to delete filters.")
                return false
            }
            
            XCTAssertEqual(targets, expectedDeleteFilters)
            return expectedDeleteFiltersResult
        } getFilterListObserver: {
            
            return stubObserver
        }
    }
    
    static func addFilterMock(expectedAddFilter: ConcreteDiaryListFilterData? = nil,
                              expectedAddFilterResult: Bool = false) -> @Sendable (any DiaryListFilterData) async -> Bool {
        
        return { data in
            
            guard let expectedAddFilter,
                  let data = data as? ConcreteDiaryListFilterData else {
                
                XCTFail("Failed to add filter.")
                return false
            }
            
            XCTAssertEqual(data, expectedAddFilter)
            return expectedAddFilterResult
        }
    }
}
