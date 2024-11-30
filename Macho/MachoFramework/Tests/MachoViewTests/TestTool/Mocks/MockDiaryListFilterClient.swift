//
//  MockDiaryListFilterClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/29.
//

import Combine
import MachoCore
import XCTest

extension DiaryListFilterClient {
    
    static func getMockClient(expectedFetchList: [ConcreteDiaryListFilterData] = [],
                              expectedAddFilter: ConcreteDiaryListFilterData? = nil,
                              expectedAddFilterResult: Bool = false,
                              expectedUpdateFilter: ConcreteDiaryListFilterData? = nil,
                              expectedUpdateFilterResult: Bool = false,
                              expectedDeleteFilters: [ConcreteDiaryListFilterData] = [],
                              expectedDeleteFiltersResult: Bool = false,
                              stubObserver: AnyPublisher<[any DiaryListFilterData], Never> = PassthroughSubject().eraseToAnyPublisher()) -> DiaryListFilterClient {
        
        return DiaryListFilterClient {
            
            return expectedFetchList
        } addFilter: { data in
            
            guard let expectedAddFilter,
                  let data = data as? ConcreteDiaryListFilterData else {
                
                XCTFail("Failed to add filter.")
                return false
            }
            
            XCTAssertEqual(data, expectedAddFilter)
            return expectedAddFilterResult
        } updateFilter: { filter in
            
            guard let expectedUpdateFilter,
                  let filter = filter as? ConcreteDiaryListFilterData else {
                
                XCTFail("Failed to update filter.")
                return false
            }
            
            XCTAssertEqual(filter, expectedUpdateFilter)
            return expectedAddFilterResult
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
}
