//
//  PopUpView.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/12/10.
//

import ComposableArchitecture
import MachoCore
import SwiftUI

struct PopUpView<
    PopUpContentView: PopUpableContentView,
    PopUpContentFeature: PopUpableContentFeature
>: View where PopUpContentView.Feature == PopUpContentFeature {
    
    @Bindable private var store: StoreOf<PopUpFeature<PopUpContentFeature>>
        
    init(store: StoreOf<PopUpFeature<PopUpContentFeature>>) {
        
        self.store = store
    }
    
    var body: some View {
        ZStack {
            if store.isShowing {
                ZStack {
                    createBackground()
                    createContentArea()
                        .padding(16)
                }
                .transition(.opacity.animation(.easeInOut))
            }
        }
        .presentationBackground(.clear)
        .onAppear {
            store.send(.onAppear)
        }
    }
}

private extension PopUpView {
    
    func createBackground() -> some View {
        Color(asset: CustomColor.dialogBackgroundColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .onTapGesture {
                store.send(.tappedBackground)
            }
    }
    
    func createContentArea() -> some View {
        PopUpContentView(store: store.scope(state: \.childState, action: \.childAction))
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(Color(asset: CustomColor.appPrimaryBackgroundColor))
            .borderModifier()
    }
}

#Preview("default") {
    PopUpView<SelectTrainingTypeContentView, SelectTrainingTypeContentFeature>(
        store: Store(initialState: PopUpFeature.State(
            childState: .init(selectingTrainingTypeList: [TrainingTypeData]())
        ),
                     reducer: { PopUpFeature() })
    )
}
