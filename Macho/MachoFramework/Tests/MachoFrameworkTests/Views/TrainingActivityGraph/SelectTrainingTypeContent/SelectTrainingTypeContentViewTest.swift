//
//  SelectTrainingTypeContentViewTest.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/12/12.
//

import Combine
import ComposableArchitecture
import XCTest

@testable import MachoView

@MainActor
final class SelectTrainingTypeContentViewTest: XCTestCase {
    
    // MARK: - test parameters
    
    private let selectableTrainingTypeList: [TrainingTypeData] = [
        .init(id: UUID(), name: "腹筋"),
        .init(id: UUID(), name: "ベンチプレス"),
        .init(id: UUID(), name: "腕立て伏せ"),
        .init(id: UUID(), name: "ああああああああああ"),
        .init(id: UUID(), name: "ええええ"),
        .init(id: UUID(), name: "ううう"),
        .init(id: UUID(), name: "おおおおおおおおおおおお")
    ]
    
    // MARK: - 正常系
    
    /// トレーニング種目を選択した時の挙動を確認
    ///
    /// # 確認仕様
    /// - 画面表示時に選択可能な登録されているトレーニング種目を全て取得する
    /// - 未選択の種目をタップすると、その種目が選択済みになる
    /// - 選択墨の種目をタップすると、その種目が未選択になる
    /// - 画面を閉じると選択内容を画面、呼び出し元に送信する(delegate actionを呼ぶ)
    /// - 閉じるボタン押下で画面が閉じること
    func testSelectTrainingTypeContent() async throws {
        
        let testStore = TestStore(initialState: .init(selectingTrainingTypeList: []),
                                  reducer: {
            SelectTrainingTypeContentFeature()
        }) {
            $0.trainingTypeApi = getMockTrainingTypeApi(expectedFetchEntity: selectableTrainingTypeList,
                                                        mockObserver: PassthroughSubject().eraseToAnyPublisher())
        }
        
        await testStore.send(.onAppear)
        await testStore.receive(\.didLoadSelectableTrainingTypeList) {
            
            $0.selectableTrainingTypeList = self.selectableTrainingTypeList
        }
        
        // 種目の選択
        await testStore.send(.tappedTrainingTypeContent(selectableTrainingTypeList[0])) {
            
            $0.selectingTrainingTypeList = [self.selectableTrainingTypeList[0]]
        }
        
        await testStore.send(.tappedTrainingTypeContent(selectableTrainingTypeList[3])) {
            
            $0.selectingTrainingTypeList.append(self.selectableTrainingTypeList[3])
        }
        
        // 種目を未選択に戻す
        await testStore.send(.tappedTrainingTypeContent(selectableTrainingTypeList[0])) {
            
            $0.selectingTrainingTypeList = [self.selectableTrainingTypeList[3]]
        }
        
        // 閉じるボタン押下
        await testStore.send(.tappedCloseButton)
        await testStore.receive(\.willDismiss)
        await testStore.receive(\.delegate)
    }
    
    /// トレーニング種目が変更された時の挙動を確認
    ///
    /// # 確認仕様
    /// - 画面表示中にトレーニング種目に変更があると、選択可能なトレーニング種目の内容も反映させる
    /// - 選択中の種目が、トレーニング種目の変更によって削除された場合、選択中の種目も更新する
    func testChangeTrainingType() async throws {
        
        // dismiss確認用のオブジェクト生成
        let isDismissInvoked = LockIsolated(false)
        let testObserver = PassthroughSubject<[TrainingTypeData], Never>()
        
        let testStore = TestStore(initialState: .init(selectingTrainingTypeList: []),
                                  reducer: {
            SelectTrainingTypeContentFeature()
        }) {
            $0.trainingTypeApi = getMockTrainingTypeApi(expectedFetchEntity: selectableTrainingTypeList,
                                                        mockObserver: testObserver.eraseToAnyPublisher())
            $0.dismiss = DismissEffect { isDismissInvoked.setValue(true) }
        }
        
        await testStore.send(.onAppear)
        await testStore.receive(\.didLoadSelectableTrainingTypeList) {
            
            $0.selectableTrainingTypeList = self.selectableTrainingTypeList
        }
        
        // 種目の選択
        await testStore.send(.tappedTrainingTypeContent(selectableTrainingTypeList[0])) {
            
            $0.selectingTrainingTypeList = [self.selectableTrainingTypeList[0]]
        }
        
        // 選択可能な種目の追加
        var expectedSelectableTrainingTypeList = self.selectableTrainingTypeList + [TrainingTypeData(id: UUID(), name: "っっっっっっ")]
        testObserver.send(expectedSelectableTrainingTypeList)
        
        await testStore.receive(\.didLoadSelectableTrainingTypeList) {
            
            $0.selectableTrainingTypeList = expectedSelectableTrainingTypeList
        }
        
        // 選択可能な種目の削除
        expectedSelectableTrainingTypeList.removeAll { $0 == self.selectableTrainingTypeList[0] }
        testObserver.send(expectedSelectableTrainingTypeList)
        
        await testStore.receive(\.didLoadSelectableTrainingTypeList) {
            
            $0.selectableTrainingTypeList = expectedSelectableTrainingTypeList
            $0.selectingTrainingTypeList = []
        }
        
        await testStore.send(.willDismiss)
        await testStore.receive(\.delegate)
    }
}

private extension SelectTrainingTypeContentViewTest {
    
    func getMockTrainingTypeApi(expectedFetchEntity: [TrainingTypeData],
                                mockObserver: AnyPublisher<[TrainingTypeData], Never>) -> TrainingTypeClient {
        
        let mockRealm = RealmAccessorMock(fetchEntity: expectedFetchEntity,
                                          expectedNotification: mockObserver)
        return TrainingTypeClient.createCustomValue(mockRealm) {
            
            return mockObserver
        }
    }
}
