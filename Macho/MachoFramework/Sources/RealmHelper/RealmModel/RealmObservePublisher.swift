//
//  RealmObservePublisher.swift
//  Macho
//
//  Created by 佐藤汰一 on 2023/11/18.
//

import Combine
import RealmSwift

// @RealmActorでしか`token`の設定を行わないため`@unchecked Sendable`とする
final class RealmObservePublisher<Output>: Publisher, @unchecked Sendable
where Output: Collection, Output.Element: BaseRealmEntity {
    
    typealias Failure = Never
    
    private var token: NotificationToken?
    private let originalPublisher = PassthroughSubject<Output, Failure>()
    
    init() {
        // nop
    }
    
    /// - Attention: RealmのEntity監視時にのみ設定する
    func setToken(_ token: NotificationToken) {
        
        self.token = token
    }
    
    func receive<S: Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Never {
        
        originalPublisher.receive(subscriber: subscriber)
    }
    
    func send(_ input: Output) {
        
        originalPublisher.send(input)
    }
}
