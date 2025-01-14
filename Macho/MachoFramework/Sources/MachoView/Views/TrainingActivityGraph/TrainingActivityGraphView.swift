//
//  TrainingActivityGraphView.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/24.
//

import Combine
import ComposableArchitecture
import SwiftUI

struct TrainingActivityGraphView: View {
    
    // MARK: - store property
    
    @Bindable private var store: StoreOf<TrainingActivityGraphFeature>
    
    // MARK: - layout property
    
    // MARK: font
    
    private let filterTitleFontSize: CGFloat = 14
    
    // MARK: size
    
    private let filterToggleIconSize: CGFloat = 30
    private let dividerHeight: CGFloat = 1
    
    // MARK: space
    
    private let filterContentBottomMargin: CGFloat = 20
    private let trainingTypeListLeadingMargin: CGFloat = 30
    private let trainingTypeListSpace: CGFloat = 8
    private let contentHorizontalPadding: CGFloat = 16
    private let filterTitleBottomPadding: CGFloat = 16
    private let filterItemRowSpace: CGFloat = 10
    private let filterButtonPadding: CGFloat = 4
    private let buttonPadding: CGFloat = 8
    
    // MARK: other
    
    private let borderCornerRadius: CGFloat = 8
    private let shadowCornerRadius: CGFloat = 8
    private let shadowYOffset: CGFloat = 8
    private let filterDividerTransitionYOffset: CGFloat = -100
    
    // MARK: - initialize method
    
    init(store: StoreOf<TrainingActivityGraphFeature>) {
        
        self.store = store
    }
    
    // MARK: - view body
    
    var body: some View {
        VStack(spacing: .zero) {
            createFilterSettingArea()
                .frame(maxWidth: .infinity)
            ScrollView {
                LazyVStack(spacing: .zero) {
                    ActivityCalendarView(store: store.scope(state: \.calendar, action: \.calendar))
                }
                .frame(maxHeight: .infinity)
                .padding(.horizontal, 16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Activity")
        .fullScreenCover(item: $store.scope(state: \.selectTrainingPopUp,
                                            action: \.selectTrainingPopUp)) {
            PopUpView<SelectTrainingTypeContentView, SelectTrainingTypeContentFeature>(store: $0)
        }
        .transaction { $0.disablesAnimations = true }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

private extension TrainingActivityGraphView {
    
    func createFilterSettingArea() -> some View {
        VStack(spacing: .zero) {
            if store.isShowingFilter {
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
                .padding(.horizontal, contentHorizontalPadding)
                .transition(
                    .move(edge: .top)
                    .combined(with: .opacity)
                )
            }
            Spacer()
                .frame(maxHeight: filterContentBottomMargin)
            Button {
                store.send(.tappedFilterDisplayButton,
                           animation: .spring)
            } label: {
                Image(systemName: store.isShowingFilter ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                    .resizable()
                    .padding(buttonPadding)
                    .frame(width: filterToggleIconSize,
                           height: filterToggleIconSize)
                    .accessibilityHidden(true)
            }
            .frameButtonStyle(frameWidth: .zero)
            if store.isShowingFilter {
                Rectangle()
                    .frame(maxWidth: .infinity,
                           maxHeight: dividerHeight)
                    .ignoresSafeArea()
                    .shadow(radius: shadowCornerRadius,
                            y: shadowYOffset)
                    .transition(
                        .offset(y: filterDividerTransitionYOffset)
                        .combined(with: .opacity)
                    )
            }
        }
        .gesture(
            DragGesture()
                .onEnded {
                    store.send(.onDragEndedFilterArea(result: .init(startLocation: $0.startLocation,
                                                                    currentLocation: $0.location)),
                               animation: .spring)
                }
        )
    }
    
    func createStartActivityPeriodDateFilterRow() -> some View {
        HStack {
            Text("表示開始日時")
                .font(.system(size: filterTitleFontSize))
            Spacer()
            DatePickerView(date: $store.activityStartPeriod.sending(\.didSelectActivityStartPeriodMenu))
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
            Spacer(minLength: trainingTypeListLeadingMargin)
            ScrollView(.horizontal) {
                HStack(spacing: trainingTypeListSpace) {
                    ForEach(store.selectingTrainingTypeNameList, id: \.self) {
                        Text($0)
                            .font(.system(size: filterTitleFontSize))
                            .padding(buttonPadding)
                            .foregroundStyle(Color(asset: CustomColor.fillButtonForegroundColor))
                            .background(.black)
                            .borderModifier(cornerRadius: borderCornerRadius)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}

// MARK: - preview

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
    var previewUserDefault: UserDefaults {
        
        // swiftlint:disable:next force_unwrapping
        let userDefaults = UserDefaults(suiteName: "preview")!
        userDefaults.setStringArray([
            selectableTrainingTypeList[0].id.uuidString,
            selectableTrainingTypeList[4].id.uuidString
        ],
                                    .targetTrainingTypeList)
        return userDefaults
    }
    TrainingActivityGraphView(store: Store(initialState: .init(),
                                           reducer: { TrainingActivityGraphFeature() }, withDependencies: {
        $0.defaultAppStorage = previewUserDefault
        $0.trainingTypeApi = .init(add: { _ in true },
                                   update: { _ in true },
                                   fetchAll: {
            return selectableTrainingTypeList
        }, getPublisher: {
            return PassthroughSubject().eraseToAnyPublisher()
        })
    }))
    .environment(\.locale, Locale(identifier: "ja_JP"))
}
