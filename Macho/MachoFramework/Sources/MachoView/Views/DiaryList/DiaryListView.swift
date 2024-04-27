//
//  DiaryListView.swift
//  Macho
//
//  Created by 佐藤汰一 on 2024/01/07.
//

import ComposableArchitecture
import SwiftUI

struct DiaryListView: View {
    
    // MARK: - tca store property
    
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
    private let indicatorHeight: CGFloat = 100
    
    // MARK: font property
    
    private let navigationTitleFontSize: CGFloat = 20
    private let filterButtonFontSize: CGFloat = 15
    
    // MARK: padding property
    
    private let controlSectionPaddingHorizontal: CGFloat = 19
    private let graphButtonPaddingTrailing: CGFloat = 8
    private let controlSectionPaddingBottom: CGFloat = 8
    private let controlSectionContentsPaddingBottom: CGFloat = 16
    
    // MARK: radius property
    
    private let filetrButtonRadius: CGFloat = 8
    
    // MARK: - view property
    
    var body: some View {
        NavigationStack {
            createMainView()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("Diary List")
                            .font(.system(size: navigationTitleFontSize))
                    }
                }
        }
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
                        createListSection(viewStore: viewStore)
                        IndicatorView(isShowing: viewStore.isBounced && viewStore.isLoadingDiaries)
                            .frame(maxHeight: indicatorHeight)
                        Spacer()
                    }
                    if viewStore.isScrolling {
                        createControlHeaderView(viewStore: viewStore)
                    }
                }
                .toolbar(viewStore.isScrolling ? .hidden : .visible, for: .navigationBar)
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

// MARK: - preview

#Preview {
    DiaryListView(store: Store(initialState: DiaryListFeature.State()) { DiaryListFeature()
    })
}
