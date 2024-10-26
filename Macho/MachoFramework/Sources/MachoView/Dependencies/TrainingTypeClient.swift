//
//  TrainingTypeClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/10/26.
//

import ComposableArchitecture
import Foundation
import RealmHelper

struct TrainingTypeClient {

    /// 登録されているすべてのトレーニング種目を取得する
    var fetchAllType: () async -> [TrainingTypeEntity]
}

extension TrainingTypeClient: DependencyKey {

    static var liveValue: TrainingTypeClient = .createCustomValue()

    static func createCustomValue(_ realm: RealmAccessible = RealmAccessor()) -> TrainingTypeClient {

        return TrainingTypeClient { await fetchAllType(realm) }
    }
}

private extension TrainingTypeClient {

    static func fetchAllType(_ realm: RealmAccessible) async -> [TrainingTypeEntity] {

        return await realm.read(where: nil)
    }
}

extension DependencyValues {

    var trainingTypeApi: TrainingTypeClient {

        get { self[TrainingTypeClient.self] }
        set { self[TrainingTypeClient.self] = newValue }
    }
}
