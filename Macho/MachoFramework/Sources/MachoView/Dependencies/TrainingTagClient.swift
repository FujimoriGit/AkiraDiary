//
//  TrainingTagClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/10/26.
//

import ComposableArchitecture
import RealmHelper

struct TrainingTagClient {

    /// 登録しているタグをすべて取得する
    var fetchAll: () async -> [TrainingTagEntity]
}

extension TrainingTagClient: DependencyKey {

    static var liveValue: TrainingTagClient = .createCustomValue()

    static func createCustomValue(_ realm: RealmAccessible = RealmAccessor()) -> TrainingTagClient {

        return TrainingTagClient { await fetchAllTag(realm) }
    }
}

private extension TrainingTagClient {

    static func fetchAllTag(_ realm: RealmAccessible) async -> [TrainingTagEntity] {

        return await realm.read(where: nil)
    }
}

extension DependencyValues {

    var trainingTagApi: TrainingTagClient {

        get { self[TrainingTagClient.self] }
        set { self[TrainingTagClient.self] = newValue }
    }
}
