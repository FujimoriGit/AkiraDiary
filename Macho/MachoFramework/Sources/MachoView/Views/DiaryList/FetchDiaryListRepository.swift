//
//  FetchDiaryListRepository.swift
//
//
//  Created by 佐藤汰一 on 2024/04/06.
//

import ComposableArchitecture
import Foundation

struct FetchDiaryListRepository {
    
    // TODO: 戻り値の型を日記アイテムに変える
    let fetch: (Date) async throws -> [String]
}
