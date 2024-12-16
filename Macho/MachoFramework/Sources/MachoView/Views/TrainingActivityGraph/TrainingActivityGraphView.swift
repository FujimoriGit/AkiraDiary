//
//  TrainingActivityGraphView.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/24.
//

import ComposableArchitecture
import SwiftUI

struct TrainingActivityGraphView: View {
    
    // MARK: - store property
    
    @Bindable private var store: StoreOf<TrainingActivityGraphFeature>
    
    // MARK: - layout property
    
    // MARK: font
    
    private let filterTitleFontSize: CGFloat = 14
    
    // MARK: space
    
    private let contentHorizontalPadding: CGFloat = 16
    private let filterTitleBottomPadding: CGFloat = 16
    private let filterItemRowSpace: CGFloat = 10
    private let filterButtonPadding: CGFloat = 4
    
    // MARK: - initialize method
    
    init(store: StoreOf<TrainingActivityGraphFeature>) {
        
        self.store = store
    }
    
    // MARK: - view body
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: .zero) {
                createFilterSettingArea()
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, contentHorizontalPadding)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Activity")
        .fullScreenCover(item: $store.scope(state: \.destination, action: \.destination)) {
            switch $0.case {
            case .selectTrainingTypePopUp(let store):
                PopUpView<SelectTrainingTypeContentView, SelectTrainingTypeContentFeature>(store: store)
            }
        }
        .transaction { $0.disablesAnimations = true }
    }
}

private extension TrainingActivityGraphView {
    
    func createFilterSettingArea() -> some View {
        VStack(alignment: .leading, spacing: .zero) {
            Text("Filter")
                .font(.system(size: filterTitleFontSize,
                              weight: .bold))
            Spacer()
                .frame(maxHeight: filterTitleBottomPadding)
            VStack(spacing: filterItemRowSpace) {
                createStartActivityPeriodDateFilterRow()
                createActivityPeriodFilterRow()
                createTrainingTypeFilterRow()
            }
        }
    }
    
    func createStartActivityPeriodDateFilterRow() -> some View {
        HStack {
            Text("表示開始日時")
                .font(.system(size: filterTitleFontSize))
            Spacer()
            DatePickerView(date: $store.viewState.activityStartPeriod.sending(\.didSelectActivityStartPeriodMenu))
        }
    }
    
    func createActivityPeriodFilterRow() -> some View {
        HStack(spacing: .zero) {
            Text("表示開始期間")
                .font(.system(size: filterTitleFontSize))
            Spacer()
            Menu {
                ForEach(ActivityPeriod.allCases, id: \.self) { period in
                    Button {
                        store.send(.didSelectActivityPeriodMenu(period))
                    } label: {
                        Text(period.title)
                    }
                }
            } label: {
                Text(store.currentActivityPeriodTitle)
                    .font(.system(size: filterTitleFontSize))
                    .padding(filterButtonPadding)
            }
            .frameButtonStyle(frameWidth: .zero)
        }
    }
    
    func createTrainingTypeFilterRow() -> some View {
        HStack(spacing: .zero) {
            Button {
                store.send(.tappedTargetTrainingTypeMenu)
            } label: {
                Text("種目")
                    .font(.system(size: filterTitleFontSize))
                    .padding(filterButtonPadding)
            }
            .frameButtonStyle(frameWidth: .zero)
            Spacer()
        }
    }
}

// MARK: - preview

#Preview {
    TrainingActivityGraphView(store: Store(initialState: .init(),
                                           reducer: { TrainingActivityGraphFeature() }, withDependencies: {
        // swiftlint:disable:next force_unwrapping
        $0.defaultAppStorage = UserDefaults(suiteName: "preview")!
    }))
    .environment(\.locale, Locale(identifier: "ja_JP"))
}
