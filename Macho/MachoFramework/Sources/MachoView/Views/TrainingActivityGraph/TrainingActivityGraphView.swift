//
//  TrainingActivityGraphView.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/24.
//

import Combine
import ComposableArchitecture
import MachoCore
import SwiftUI

struct TrainingActivityGraphView: View {
    
    // MARK: - store property
    
    @Bindable private var store: StoreOf<TrainingActivityGraphFeature>
    
    // MARK: - layout property
    
    // MARK: size
    
    private let filterToggleIconSize: CGFloat = 30
    private let dividerHeight: CGFloat = 1
    
    // MARK: space
    
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
                    ActivityCalendarView(store: store.scope(state: \.calendar,
                                                            action: \.calendar))
                }
                .frame(maxHeight: .infinity)
                .padding(.horizontal, .space(.medium))
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationButton(.back) {
                    store.send(.tappedNavigationBackButton)
                }
            }
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Activity")
        .alert(store: store.scope(state: \.$alert, action: \.alert))
        .navigationDestination(item: $store.scope(state: \.navigationDestination?.detailScreen,
                                                  action: \.navigationDestination.detailScreen)) {
            DiaryDetailView(store: $0)
        }
        .fullScreenCover(item: $store.scope(state: \.popup,
                                            action: \.popup)) {
            createPopupView($0.case)
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
                        .font(.macho(.subTitle))
                    Spacer()
                        .frame(maxHeight: .space(.medium))
                    VStack(spacing: .space(.small)) {
                        createStartActivityPeriodDateFilterRow()
                        createActivityPeriodFilterRow()
                        createTrainingTypeFilterRow()
                    }
                }
                .padding(.horizontal, .space(.medium))
                .transition(
                    .move(edge: .top)
                    .combined(with: .opacity)
                )
            }
            Spacer()
                .frame(maxHeight: .space(.large))
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
                    store.send(.onDragEndedFilterArea(result: .init(
                        startLocation: $0.startLocation,
                        currentLocation: $0.location
                    )),
                               animation: .spring)
                }
        )
    }
    
    func createStartActivityPeriodDateFilterRow() -> some View {
        HStack {
            Text("表示開始日時")
                .font(.macho(.subTitle))
            Spacer()
            DatePickerView(date: $store.activityStartPeriod.sending(\.didSelectActivityStartPeriodMenu),
                           titleFont: .macho(.subTitle))
        }
    }
    
    func createActivityPeriodFilterRow() -> some View {
        HStack(spacing: .zero) {
            Text("表示開始期間")
                .font(.macho(.subTitle))
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
                    .font(.macho(.subTitle))
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
                    .font(.macho(.subTitle))
                    .padding(filterButtonPadding)
            }
            .frameButtonStyle(frameWidth: .zero)
            Spacer(minLength: .space(.large))
            ScrollView(.horizontal) {
                HStack(spacing: .space(.small)) {
                    ForEach(store.selectingTrainingTypeNameList, id: \.self) {
                        Text($0)
                            .font(.macho(.subTitle))
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
    
    @ViewBuilder
    func createPopupView(_ storeCase: TrainingActivityGraphFeature.PopUpDestination.CaseScope) -> some View {
        
        switch storeCase {
            
        case .selectTraining(let store):
            PopUpView<
                SelectTrainingTypeContentView,
                SelectTrainingTypeContentFeature
            >(store: store)
            
        case .detailDayOfActivity(let store):
            PopUpView<
                DetailDayOfActivityView,
                DetailDayOfActivityFeature
            >(store: store)
        }
    }
}

// MARK: - preview

#Preview {
    
    @Environment(\.calendar)
    @Previewable var calendar
    
    let absId = UUID()
    let benchPressId = UUID()
    let diaryId = UUID()
    
    var fetchDiaries: [DiaryData] {
        [
            .init(id: diaryId,
                  date: .now,
                  title: "Test1",
                  mainText: "",
                  goals: [
                    .init(id: UUID(),
                          trainingType: .init(id: absId, name: "aaa"),
                          goalNumberOfSets: 3,
                          goalSetCount: 3,
                          actualNumberOfSets: 3,
                          actualSetCount: 3,
                          isAchieved: true)
                  ],
                  tags: [],
                  startTime: nil,
                  endTime: nil)
        ]
    }
    var selectableTrainingTypeList: [TrainingTypeData] {
        
        [
            .init(id: absId, name: "腹筋"),
            .init(id: benchPressId, name: "ベンチプレス")
        ]
    }
    var previewUserDefault: UserDefaults {
        
        // swiftlint:disable:next force_unwrapping
        let userDefaults = UserDefaults(suiteName: "preview")!
        userDefaults.setStringArray([
            selectableTrainingTypeList[0].id.uuidString
        ],
                                    .targetTrainingTypeList)
        userDefaults.setDouble(
            Date.now.addingTimeInterval(-(60 * 60 * 24 * 7)).timeIntervalSince1970,
            .activityStartPeriod
        )
        userDefaults.setInt(ActivityPeriod.month.rawValue, .activityPeriod)
        return userDefaults
    }
    
    NavigationView {
        TrainingActivityGraphView(store: Store(initialState: .init(),
                                               reducer: { TrainingActivityGraphFeature() },
                                               withDependencies: {
            $0.defaultAppStorage = previewUserDefault
            $0.trainingTypeClient = .init(fetchAllType: { return selectableTrainingTypeList },
                                          add: { _ in true },
                                          getObserve: {
                
                return PassthroughSubject().eraseToAnyPublisher()
            })
            $0.diaryEntityClient = .init(fetchAll: {
                
                return fetchDiaries
            },
                                         add: { _ in true },
                                         deleteDiary: { _ in true },
                                         getDiaryObserver: {
                
                return PassthroughSubject().eraseToAnyPublisher()
            })
        }))
    }
    .environment(\.locale, Locale(identifier: "ja_JP"))
}

#Preview("日記なしのケース") {
    
    TrainingActivityGraphView(store: Store(
        initialState: .init(),
        reducer: { TrainingActivityGraphFeature() },
        withDependencies: {
            
            // swiftlint:disable:next force_unwrapping
            $0.defaultAppStorage = UserDefaults(suiteName: "日記なしのケース")!
        }
    ))
}
