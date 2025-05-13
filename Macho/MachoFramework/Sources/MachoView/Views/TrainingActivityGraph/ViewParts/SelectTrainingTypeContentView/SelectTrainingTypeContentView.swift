//
//  SelectTrainingTypeContentView.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/12/10.
//

import Combine
import ComposableArchitecture
import Foundation
import MachoCore
import SwiftUI

struct SelectTrainingTypeContentView: PopUpableContentView {
    
    typealias Feature = SelectTrainingTypeContentFeature
    
    // MARK: - store property
    
    @Bindable private var store: StoreOf<SelectTrainingTypeContentFeature>
    
    // MARK: - layout property
    
    // MARK: font size
    
    private let titleFontSize: CGFloat = 20
    
    // MARK: content size
    
    private let contentHeight: CGFloat = 300
    private let iconSize: CGFloat = 20
    
    // MARK: space
    
    private let titleBottomMargin: CGFloat = 20
    private let trainingTypeContentsSpace: CGFloat = 8
    private let iconTrailingSpace: CGFloat = 4
    private let trainingTypeContentPadding: CGFloat = 8
    
    // MARK: other
    
    private let trainingTypeContentRadius: CGFloat = 8
    
    // MARK: - initialize method
    
    init(store: some StoreOf<SelectTrainingTypeContentFeature>) {
        
        self.store = store
    }
    
    // MARK: - view definition
    
    var body: some View {
        ZStack {
            Button {
                store.send(.tappedCloseButton)
            } label: {
                Image(systemName: "xmark.circle")
                    .resizable()
                    .frame(width: iconSize, height: iconSize)
                    .padding(8)
            }
            .frameButtonStyle(frameWidth: .zero)
            .frame(maxWidth: .infinity,
                   maxHeight: .infinity,
                   alignment: .topTrailing)
            .zIndex(.infinity)
            VStack(alignment: .leading, spacing: .zero) {
                Text("種目の選択")
                    .font(.system(size: titleFontSize, weight: .bold))
                Spacer()
                    .frame(maxHeight: titleBottomMargin)
                ScrollView {
                    FlowLayout(alignment: .leading,
                               spacing: trainingTypeContentsSpace) {
                        ForEach(store.selectableTrainingTypeList) {
                            createTrainingTypeContent($0)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .frame(maxHeight: contentHeight)
        .onAppear {
            store.send(.onAppear)
        }
    }
}

// MARK: - private method

private extension SelectTrainingTypeContentView {
    
    @ViewBuilder
    func createTrainingTypeContent(_ targetType: TrainingTypeData) -> some View {
        let isSelectingTrainingType = isSelectingTrainingType(targetType)
        Button {
            store.send(.tappedTrainingTypeContent(targetType),
                       animation: .spring)
        } label: {
            HStack(spacing: iconTrailingSpace) {
                Image(systemName: isSelectingTrainingType ? "checkmark.circle" : "circle")
                    .resizable()
                    .frame(width: iconSize, height: iconSize)
                    .accessibilityHidden(true)
                Text(targetType.name)
            }
            .padding(trainingTypeContentPadding)
        }
        // TODO: 色は仮決め
        .fillButtonStyle(
            foregroundColor: Color(asset: CustomColor.fillButtonForegroundColor),
            backgroundColor: Color(
                asset: isSelectingTrainingType ?
                CustomColor.fillButtonBackgroundColor :
                    CustomColor.deleteSwipeBackgroundColor
            ),
            cornerRadius: trainingTypeContentRadius
        )
    }
    
    func isSelectingTrainingType(_ targetType: TrainingTypeData) -> Bool {
        
        return store.selectingTrainingTypeList.contains {
            
            return targetType == $0
        }
    }
}

#Preview {
    let selectableTrainingTypeList: [TrainingTypeData] = [
        .init(id: UUID(), name: "腹筋"),
        .init(id: UUID(), name: "ベンチプレス"),
        .init(id: UUID(), name: "腕立て伏せ"),
        .init(id: UUID(), name: "ああああああああああ"),
        .init(id: UUID(), name: "ええええ"),
        .init(id: UUID(), name: "ううう"),
        .init(id: UUID(), name: "おおおおおおおおおおおお")
    ]
    PopUpView<SelectTrainingTypeContentView, SelectTrainingTypeContentFeature>(
        store: Store(initialState: PopUpFeature.State(
            childState: .init(selectingTrainingTypeList: [
                selectableTrainingTypeList[0],
                selectableTrainingTypeList[3]
            ])
        ),
                     reducer: { PopUpFeature() },
                     withDependencies: {
                         $0.trainingTypeClient = TrainingTypeClient(fetchAllType: {
                             
                             return selectableTrainingTypeList
                         },
                                                                    add: { _ in false },
                                                                    getObserve: {
                             
                             return PassthroughSubject().eraseToAnyPublisher()
                         })
                     })
    )
}
