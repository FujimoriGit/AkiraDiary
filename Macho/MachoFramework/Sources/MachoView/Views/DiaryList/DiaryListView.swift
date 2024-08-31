//
//  DiaryListView.swift
//  Macho
//
//  Created by 佐藤汰一 on 2024/01/07.
//

import Combine
import ComposableArchitecture
import SwiftUI

@MainActor
struct DiaryListView: View {
    
    // MARK: - TCA store property
    
    @Bindable private var store: StoreOf<DiaryListFeature>
    
    // MARK: - initialize method
    
    init(store: StoreOf<DiaryListFeature>) {
        
        self.store = store
    }
    
    // MARK: - layout property
    
    // MARK: size property
    
    private let controlSectionHeight: CGFloat = 100
    private let filterIconSize: CGFloat = 16
    private let graphIconSize: CGSize = .init(width: 39, height: 39)
    private let diaryItemMinHeightSize: CGFloat = 75
    
    // MARK: font property
    
    private let navigationTitleFontSize: CGFloat = 20
    private let filterButtonFontSize: CGFloat = 15
    private let emptyMessageFontSize: CGFloat = 20
    
    // MARK: padding property
    
    private let controlSectionPaddingHorizontal: CGFloat = 19
    private let graphButtonPaddingTrailing: CGFloat = 8
    private let controlSectionPaddingBottom: CGFloat = 8
    private let controlSectionContentsPaddingBottom: CGFloat = 16
    private let emptyMessagePaddingHorizontal: CGFloat = 16
    
    // MARK: radius property
    
    private let filterButtonRadius: CGFloat = 8
    
    // MARK: - view property
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            createMainView()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("Diary List")
                            .font(.system(size: navigationTitleFontSize))
                    }
                }
        } destination: {
            getNavigationDestination($0)
        }
        .alert(store: store.scope(state: \.$alert, action: \.alert))
        .transaction { $0.disablesAnimations = false }
        .fullScreenCover(item: $store.scope(state: \.destination, action: \.destination)) {
            getModalDestination($0)
                .presentationBackground(.clear)
        }
        .transaction { $0.disablesAnimations = true }
    }
}

// MARK: - private extension

private extension DiaryListView {
    
    func createMainView() -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                VStack(spacing: .zero) {
                    if !store.viewState.isScrolling {
                        createControlSection()
                    }
                    if store.viewState.hasDiaryItems {
                        createListSection()
                    }
                    else {
                        createEmptyListView()
                    }
                    Spacer()
                }
                if store.viewState.isScrolling {
                    createControlHeaderView()
                }
            }
            .toolbar(store.viewState.isScrolling ? .hidden : .visible, for: .navigationBar)
            .onAppear {
                store.send(.onAppearView)
            }
            .frame(width: geometry.size.width,
                   height: geometry.size.height)
        }
    }
    
    func createControlSection() -> some View {
        VStack {
            createControlHeaderView()
            Spacer()
                .frame(height: controlSectionContentsPaddingBottom)
            Divider()
                .frame(maxWidth: .infinity)
        }
        .background(Color(asset: CustomColor.appPrimaryBackgroundColor))
    }
    
    func createListSection() -> some View {
        TrackableList(store: store.scope(state: \.trackableList, action: \.trackableList)) {
            ForEachStore(store.scope(state: \.diaries,
                                     action: \.diaries)) { store in
                DiaryListItemView(store: store)
                    .frame(minHeight: diaryItemMinHeightSize)
            }
        }
        .scrollIndicators(.hidden)
    }
    
    func createEmptyListView() -> some View {
        Text("表示する日記がありません")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, emptyMessagePaddingHorizontal)
            .font(.system(size: emptyMessageFontSize, weight: .bold))
            .foregroundStyle(Color(asset: CustomColor.appPrimaryTextColor))
            .multilineTextAlignment(.center)
    }
    
    func createControlHeaderView() -> some View {
        HStack(spacing: .zero) {
            createFilterButton {
                store.send(.tappedFilterButton)
            }
            Spacer()
            createGraphButton {
                store.send(.tappedGraphButton)
            }
            Spacer()
                .frame(width: graphButtonPaddingTrailing)
            createNewDiaryButton {
                store.send(.tappedCreateNewDiaryButton)
            }
        }
        .padding(.horizontal, controlSectionPaddingHorizontal)
        .background(Color(asset: CustomColor.scrollingToolBarAreaBackgroundColor))
    }
    
    func createFilterButton(_ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text("filter")
                    .font(.system(size: filterButtonFontSize, weight: .regular))
                    .foregroundStyle(.white)
                Image(systemName: "arrowtriangle.down.fill")
                    .foregroundStyle(Color.white)
                    .font(.system(size: filterIconSize))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .clipped()
            .background(Color.gray.clipShape(RoundedRectangle(cornerRadius: filterButtonRadius)))
        }
    }
    
    func createGraphButton(_ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(asset: CustomImage.graphCircle)
                .resizable()
                .frame(width: graphIconSize.width,
                       height: graphIconSize.height)
        }
    }
    
    func createNewDiaryButton(_ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(asset: CustomImage.plusCircle)
                .resizable()
                .frame(width: graphIconSize.width,
                       height: graphIconSize.height)
        }
    }
}

// MARK: - Navigation Stack Route Definition

private extension DiaryListView {
    
    func getNavigationDestination(_ store: Store<DiaryListFeature.Path.State,
                                  DiaryListFeature.Path.Action>) -> some View {
        
        switch store.case {
            
        // TODO: 実装出来次第正しい画面に変更する
        case .editScreen(let editScreenStore):
            AddContactView(store: editScreenStore)
            
        case .createScreen(let createScreenStore):
            AddContactView(store: createScreenStore)
            
        case .graphScreen(let graphScreenStore):
            AddContactView(store: graphScreenStore)
            
        case .detailScreen(let detailScreenStore):
            AddContactView(store: detailScreenStore)
        }
    }
}

// MARK: - Modal Presentation Route Definition

private extension DiaryListView {
    
    func getModalDestination(_ store: Store<DiaryListFeature.Destination.State,
                             DiaryListFeature.Destination.Action>) -> some View {
        
        switch store.case {
            
        case .filterScreen(let filterScreenStore):
            DiaryListFilterView(store: filterScreenStore)
        }
    }
}

// MARK: - preview

#Preview {
    PreviewDiaryListView()
}

struct PreviewDiaryListView: View {
    
    private let state: DiaryListFeature.State
    private let publisher = PassthroughSubject<[DiaryListFilterItem], Never>()
    @State private var currentFilters = [
        DiaryListFilterItem(id: UUID(),
                            target: .achievement,
                            value: "達成していない"),
        DiaryListFilterItem(id: UUID(),
                            target: .trainingType,
                            value: "腹筋")
    ]
    
    init() {
        
        var diaries: IdentifiedArrayOf<DiaryListItemFeature.State> = []
        
        for num in 0...10 {
            diaries.append(DiaryListItemFeature.State(title: "\(num)",
                                                      message: "",
                                                      date: Date(),
                                                      isWin: true,
                                                      trainingList: ["腹筋", "ベンチプレス", "ダンベルプレス"]))
        }
        
        self.state = DiaryListFeature.State(diaries: diaries)
    }
    
    var body: some View {
        DiaryListView(store: Store(initialState: state) {
            withDependencies {
                // 日記リスト取得のAPI DI
                $0.diaryListFetchApi = DiaryListItemClient(fetch: { _, _ in
                    if Int.random(in: 0...10) <= 5 {
                        return [
                            .init(title: "fetch item",
                                  message: "sample",
                                  date: Date(),
                                  isWin: false,
                                  trainingList: ["腹筋", "ベンチプレス", "ダンベルプレス"])
                        ]
                    }
                    else {
                        throw URLError(.badURL)
                    }
                }, deleteItem: { _ in })
                // フィルター取得API DI
                $0.diaryListFilterApi = DiaryListFilterClient(addFilter: { filter in
                    
                    currentFilters += [filter]
                    publisher.send(currentFilters)
                    return true
                }, updateFilter: { filter in
                    
                    guard let index = currentFilters.firstIndex(where: { $0.target == filter.target })
                    else { return false }
                    currentFilters[index] = filter
                    publisher.send(currentFilters)
                    return true
                }, deleteFilters: { targets in
                    
                    currentFilters = currentFilters.filter { !targets.contains($0) }
                    publisher.send(currentFilters)
                    return true
                }, fetchFilterList: {
                    
                    return currentFilters
                }, getFilterListObserver: {
                    
                    return publisher.eraseToAnyPublisher()
                })
            } operation: {
                DiaryListFeature()
            }
        })
    }
}
