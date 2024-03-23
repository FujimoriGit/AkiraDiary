//
//  DiaryListView.swift
//  Macho
//
//  Created by 佐藤汰一 on 2024/01/07.
//

import ComposableArchitecture
import SwiftUI

struct DiaryListView: View {
    
    var store: StoreOf<DiaryListFeature>
    
    // MARK: - layout property
    
    // MARK: size property
    
    private let controlSectionHeight: CGFloat = 100
    private let filterIconSize: CGFloat = 16
    private let graphIconSize: CGSize = .init(width: 39, height: 39)
    private let diaryItemMinHeightSize: CGFloat = 120
    
    // MARK: font property
    
    private let filterButtonFontSize: CGFloat = 15
    
    // MARK: padding property
    
    private let controlSectionPaddingHorizontal: CGFloat = 19
    private let graphButtonPaddingTrailing: CGFloat = 8
    
    // MARK: radius property
    
    private let filetrButtonRadius: CGFloat = 8
    
    // MARK: - view property
    
    var body: some View {
        NavigationStack {
            createMainView()
                .navigationTitle("Diary List")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - private extension

private extension DiaryListView {
    
    func createMainView() -> some View {
        GeometryReader { geometry in
            WithViewStore(store, observe: { $0 }) { viewStore in
                ZStack {
                    if viewStore.currentScrollState.isScrolling {
                        VStack {
                            createControlHeaderView(viewStore: viewStore)
                            Spacer()
                        }
                    }
                    VStack {
                        Spacer()
                        ScrollViewReader{ proxy in
                            ScrollView(.vertical) {
                                VStack(spacing: .zero) {
                                    createControlSection(viewStore: viewStore)
                                        .frame(height: controlSectionHeight,
                                               alignment: .bottom)
                                    Spacer()
                                        .frame(height: 8) // TODO: マジックナンバー
                                    createListSection(viewStore: viewStore)
                                }
                                .background {
                                    GeometryReader { geometry in
                                        Color.clear.onChange(of: geometry.frame(in: .named("ScrollView")).minY) { _, offsetY in
                                            viewStore.send(.onScroll(state: ScrollState(offsetY: offsetY)))
                                        }
                                    }
                                }
                            }
                            .refreshable {
                                viewStore.send(.refreshList)
                            }
                            .scrollBounceBehavior(.basedOnSize)
                        }
                    }
                }
            }
            .frame(width: geometry.size.width,
                   height: geometry.size.height)
        }
    }
    
    func createControlSection(viewStore: ViewStore<DiaryListFeature.State, DiaryListFeature.Action>) -> some View {
        VStack {
            Spacer()
            createControlHeaderView(viewStore: viewStore)
            Spacer()
                .frame(height: 16) // TODO: マジックナンバー
            Divider()
                .frame(maxWidth: .infinity)
        }
    }
    
    func createListSection(viewStore: ViewStore<DiaryListFeature.State, DiaryListFeature.Action>) -> some View {
        VStack {
            ForEachStore(store.scope(state: \.diaries,
                                     action: \.diaries)) { store in
                DiaryListItemView(store: store)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(minHeight: diaryItemMinHeightSize)
                    .scrollTransition { view, phase in
                        view
                            .opacity(phase.isIdentity ? 1 : 0)
                    }
            }
        }
    }
    
    func createControlHeaderView(viewStore: ViewStore<DiaryListFeature.State, DiaryListFeature.Action>) -> some View {
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
            Image("graph_circle", bundle: nil)
                .resizable()
                .frame(width: graphIconSize.width,
                       height: graphIconSize.height)
        }
    }
    
    func createNewDiaryButton(_ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image("plus_circle", bundle: nil)
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
