//
//  DiaryListView.swift
//  Macho
//
//  Created by 佐藤汰一 on 2024/01/07.
//

import ComposableArchitecture
import SwiftUI

@MainActor
struct DiaryListView: View {
    
    // MARK: - TCA store property
    
    private var store: StoreOf<DiaryListFeature>
    
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
    
    private let filetrButtonRadius: CGFloat = 8
    
    // MARK: - view property
    
    var body: some View {
        NavigationStackStore(store.scope(state: \.path, action: \.path)) {
            createMainView()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("Diary List")
                            .font(.system(size: navigationTitleFontSize))
                    }
                }
        } destination: { getNavigationDestination($0) }
        .alert(store: store.scope(state: \.$alert, action: \.alert))
        .transaction { $0.disablesAnimations = false }
        .fullScreenCover(store: store.scope(state: \.$filterView, action: \.filterView)) {
            DiaryListFilterView(store: $0)
                .presentationBackground(.clear)
        }
        .transaction { $0.disablesAnimations = true }
    }
}

// MARK: - private extension

private extension DiaryListView {
    
    func createMainView() -> some View {
        GeometryReader { geometry in
            WithViewStore(store, observe: \.viewState) { viewStore in
                ZStack(alignment: .top) {
                    VStack(spacing: .zero) {
                        if !viewStore.isScrolling {
                            createControlSection(viewStore: viewStore)
                        }
                        if viewStore.hasDiaryItems {
                            createListSection(viewStore: viewStore)
                        }
                        else {
                            createEmptyListView()
                        }
                        Spacer()
                    }
                    if viewStore.isScrolling {
                        createControlHeaderView(viewStore: viewStore)
                    }
                }
                .toolbar(viewStore.isScrolling ? .hidden : .visible, for: .navigationBar)
                .onAppear {
                    viewStore.send(.onAppearView)
                }
            }
            .frame(width: geometry.size.width,
                   height: geometry.size.height)
        }
    }
    
    func createControlSection(viewStore: ViewStore<DiaryListFeature.State.ViewState, DiaryListFeature.Action>) -> some View {
        VStack {
            createControlHeaderView(viewStore: viewStore)
            Spacer()
                .frame(height: controlSectionContentsPaddingBottom)
            Divider()
                .frame(maxWidth: .infinity)
        }
        .background(Color(asset: CustomColor.appPrimaryBackgroundColor))
    }
    
    func createListSection(viewStore: ViewStore<DiaryListFeature.State.ViewState, DiaryListFeature.Action>) -> some View {
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
    
    func createControlHeaderView(viewStore: ViewStore<DiaryListFeature.State.ViewState, DiaryListFeature.Action>) -> some View {
        HStack(spacing: .zero) {
            createFilterButton {
                viewStore.send(.tappedFilterButton)
            }
            Spacer()
            createGraphButton {
                viewStore.send(.tappedGraphButton)
            }
            Spacer()
                .frame(width: graphButtonPaddingTrailing)
            createNewDiaryButton {
                viewStore.send(.tappedCreateNewDiaryButton)
            }
        }
        .padding(.horizontal, controlSectionPaddingHorizontal)
        .background(Color(asset: CustomColor.scrollingToolBarAreaBackgroundColor))
    }
    
    func createFilterButton(_ action: @escaping () -> Void) -> some View {
        Button(action: action){
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
            .background(Color.gray.clipShape(RoundedRectangle(cornerRadius: filetrButtonRadius)))
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
    
    func getNavigationDestination(_ state: DiaryListFeature.Path.State) -> some View {
        switch state {
            
        // TODO: 実装出来次第正しい画面に変更する
        case .editScreen(let editScreenState):
            AddContactView(store: StoreOf<AddContactFeature>(initialState: editScreenState) {
                AddContactFeature()
            })
        case .createScreen(let createScreenState):
            AddContactView(store: StoreOf<AddContactFeature>(initialState: createScreenState) {
                AddContactFeature()
            })
        case .graphScreen(let graphScreenState):
            AddContactView(store: StoreOf<AddContactFeature>(initialState: graphScreenState) {
                AddContactFeature()
            })
        case .detailScreen(let detailScreenState):
            AddContactView(store: StoreOf<AddContactFeature>(initialState: detailScreenState) {
                AddContactFeature()
            })
        }
    }
}

// MARK: - preview

#Preview {
    
    struct SampleView: View {
        
        private let state: DiaryListFeature.State
        
        init() {
            
            var diaries: IdentifiedArrayOf<DiaryListItemFeature.State> = []
            
            for i in 0...10 {
                diaries.append(DiaryListItemFeature.State(title: "\(i)", message: "", date: Date(), isWin: true))
            }
            
            self.state = DiaryListFeature.State(diaries: diaries)
        }
        
        var body: some View {
            DiaryListView(store: Store(initialState: state) {
                withDependencies {
                    $0.diaryListFetchApi = DiaryListItemClient(fetch: { startDate, limitCount in
                        if Int.random(in: 0...10) <= 5 {
                            return [.init(title: "fetch item", message: "sample", date: Date(), isWin: false)]
                        }
                        else {
                            throw NSError()
                        }
                    }, deleteItem: { _ in })
                } operation: {
                    DiaryListFeature()
                }
            })
        }
    }
    
    return SampleView()
}
