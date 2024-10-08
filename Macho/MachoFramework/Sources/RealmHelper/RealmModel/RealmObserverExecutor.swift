//
//  RealmObserverFactory.swift
//  Macho
//
//  Created by 佐藤汰一 on 2023/11/18.
//

import Combine
import RealmSwift

public class RealmObserverExecutor<T: BaseRealmEntity> {
    
    private let publisher = PassthroughSubject<[T], Never>()
    private var token: NotificationToken?
    
    /// RealmDBのデータ変更を検知するPublisherを返す
    ///
    /// startObservationを呼び出すまではPublisherは何も検知しない
    public func getPublisher() -> AnyPublisher<[T], Never> {
        
        return publisher.eraseToAnyPublisher()
    }
    
    /// RealmDBのデータ変更の監視を開始する
    public func startObservation() {
        
        Task {
            
            token = await RealmAccessor().observeDidChangeRealmObject(subject: publisher)
        }
    }
    
    /// 監視処理を終了する
    public func stopObservation() {
        
        token?.invalidate()
    }
}
