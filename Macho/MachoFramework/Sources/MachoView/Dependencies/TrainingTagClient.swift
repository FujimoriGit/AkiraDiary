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
    var addTags: ([Tag]) async -> Bool
    /// タグの更新
    var updateTag: (Tag) async -> Bool
    /// 登録しているタグをすべて取得する
    var fetchAll: () async -> [TrainingTagEntity]
    /// 監視用のPublisherを返す
    var getTrainingTagPublisher: () -> AnyPublisher<[TrainingTagEntity], Never>
}

extension TrainingTagClient: DependencyKey {

    static var liveValue: TrainingTagClient = .createCustomValue()

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
}

private extension TrainingTagClient {
    
    static func createCustomValue(_ realm: RealmAccessible = RealmAccessor(),
                                  publisher: (() -> AnyPublisher<[TrainingTagEntity], Never>)? = nil) -> TrainingTagClient {

        return TrainingTagClient {
            
            return await addTags(tags: $0)
        } updateTag: {
            
            return await updateTag(tag: $0)
        } fetchAll: {
            
            return await fetchAllTag(realm)
        } getTrainingTagPublisher: {
            
            return publisher?() ?? PassthroughSubject<[TrainingTagEntity], Never>().eraseToAnyPublisher()
        }
    }

    static func fetchAllTag(_ realm: RealmAccessible) async -> [TrainingTagEntity] {

        return await realm.read(where: nil)
    }
    
    /// DBにタグを追加します.
    static func addTags(_ realm: RealmAccessible = RealmAccessor(), tags: [Tag]) async -> Bool {
        
        if tags.isEmpty {
            
            logger.error("tags is empty.")
            return false
        }
        
        let records = tags.map {
            
            return TrainingTagEntity(id: $0.id, tagName: $0.tagName)
        }
        
        return await realm.insert(records: records)
    }
    
    static func updateTag(_ realm: RealmAccessible = RealmAccessor(), tag: Tag) async -> Bool {
        
        let value: [String: Any] = ["id": tag.id,
                            "tagTagName": tag.tagName]
        
        return await realm.update(type: TrainingTagEntity.self, value: value)
    }
}

extension DependencyValues {

    var trainingTagApi: TrainingTagClient {

        get { self[TrainingTagClient.self] }
        set { self[TrainingTagClient.self] = newValue }
    }
}
