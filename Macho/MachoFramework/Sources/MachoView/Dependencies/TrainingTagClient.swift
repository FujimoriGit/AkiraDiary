//
//  TrainingTagClient.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/10/26.
//

import Combine
import ComposableArchitecture
import Foundation
import RealmHelper

struct TrainingTagClient {

    /// タグの登録
    var add: (TrainingTagData) async -> Bool
    /// タグの更新
    var updateTag: (TrainingTagData) async -> Bool
    /// 登録しているタグをすべて取得する
    var fetchAll: () async -> [TrainingTagData]
    /// 監視用のPublisherを返す
    var getTrainingTagPublisher: () -> AnyPublisher<[TrainingTagData], Never>
}

extension TrainingTagClient: DependencyKey {

    static var liveValue: TrainingTagClient = .createCustomValue {
        
        let executor = TrainingTagEntity.executor
        executor.startObservation()
        return executor.getPublisher().eraseToAnyPublisher()
    }

    static var previewValue = TrainingTagClient { _ in
        
        return true
    } updateTag: { _ in
        
        return true
    } fetchAll: {
        
        let tagNames = [
            "もりもり",
            "トレーニング",
            "Swift",
            "iOS開発",
            "SwiftUI",
            "UIKit",
            "WWDC",
            "Python",
            "JavaScript",
            "PHP",
            "Ruby",
            "Flutter",
            "Dart",
            "Android",
            "iPhone",
            "あきら",
            "たいち"
        ]
        
        return tagNames.map { TrainingTagEntity(id: UUID(), tagName: $0) }
    } getTrainingTagPublisher: {
        
        return PassthroughSubject<[TrainingTagEntity], Never>().eraseToAnyPublisher()
    }
    
    static func createCustomValue(
        _ realm: RealmAccessible = RealmAccessor(),
        publisher: (() -> AnyPublisher<[TrainingTagEntity], Never>)? = nil
    ) -> TrainingTagClient {

        return TrainingTagClient {
            
            return await addTags(realm, tag: $0)
        } updateTag: {
            
            return await updateTag(realm, tag: $0)
        } fetchAll: {
            
            return await fetchAllTag(realm)
        } getTrainingTagPublisher: {
            
            return publisher?() ?? PassthroughSubject<[TrainingTagEntity], Never>().eraseToAnyPublisher()
        }
    }
}

private extension TrainingTagClient {

    static func fetchAllTag(_ realm: RealmAccessible) async -> [TrainingTagEntity] {

        return await realm.read(where: nil)
    }
    
    /// DBにタグを追加します.
    static func addTags(_ realm: RealmAccessible = RealmAccessor(), tag: TrainingTagData) async -> Bool {
        
        guard await fetchAllTag(realm).contains(where: { $0.tagName == tag.tagName }) else {
            
            logger.error("same name already added.")
            return false
        }
        
        let record = TrainingTagEntity(id: tag.id, tagName: tag.tagName)
        
        return await realm.insert(records: [record])
    }
    
    static func updateTag(_ realm: RealmAccessible = RealmAccessor(), tag: TrainingTagData) async -> Bool {
        
        let value: [String: Any] = ["id": tag.id, "tagName": tag.tagName]
        
        return await realm.update(type: TrainingTagEntity.self, value: value)
    }
}

extension DependencyValues {

    var trainingTagApi: TrainingTagClient {

        get { self[TrainingTagClient.self] }
        set { self[TrainingTagClient.self] = newValue }
    }
}
