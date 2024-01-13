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
    
    // MARK: layout property
    // size property
    private let controlSectionHeight: CGFloat = 100
    private let filterIconSize: CGFloat = 16
    private let graphIconSize: CGSize = .init(width: 39, height: 39)
    private let diaryItemMinHeightSize: CGFloat = 120
    
    // font property
    private let filterButtonFontSize: CGFloat = 15
    
    // padding property
    private let controlSectionPaddingHorizontal: CGFloat = 19
    
    // radius property
    private let filetrButtonRadius: CGFloat = 8

    var body: some View {
        NavigationStack {
            createMainView()
            .navigationTitle("Diary List")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private extension DiaryListView {
    
    func createMainView() -> some View {
        GeometryReader { geometry in
            WithViewStore(store, observe: { $0 }) { viewStore in
                VStack {
                    createControlSection(viewStore: viewStore)
                        .frame(height: controlSectionHeight, alignment: .bottom)
                    Divider()
                    Spacer()
                    ScrollView(.vertical) {
                        createListSection(viewStore: viewStore)
                    }
                    .refreshable {
                        viewStore.send(.refreshList)
                    }
                }
            }
            .frame(width: geometry.size.width,
                   height: geometry.size.height)
        }
    }
    
    func createControlSection(viewStore: ViewStore<DiaryListFeature.State, DiaryListFeature.Action>) -> some View {
        HStack {
            // filterボタン
            Button(action: {
                viewStore.send(.tappedFilterButton)
            }, label: {
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
            })
            
            Spacer()
            
            // グラフボタン
            Button(action: {
                viewStore.send(.tappedGraphButton)
            }, label: {
                Image("graph_circle", bundle: nil)
                    .resizable()
                    .frame(width: graphIconSize.width,
                           height: graphIconSize.height)
            })
            
            // 日記新規作成ボタン
            Button(action: {
                viewStore.send(.tappedCreateNewDiaryButton)
            }, label: {
                Image("plus_circle", bundle: nil)
                    .resizable()
                    .frame(width: graphIconSize.width,
                           height: graphIconSize.height)
            })
        }
        .padding(.horizontal, controlSectionPaddingHorizontal)
    }
    
    func createListSection(viewStore: ViewStore<DiaryListFeature.State, DiaryListFeature.Action>) -> some View {
        VStack {
            ForEachStore(store.scope(state: \.diaries, action: { .diaries(id: $0.0, action: $0.1) })) { store in
                DiaryListItemView(store: store)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(minHeight: diaryItemMinHeightSize)
            }
        }
    }
}

#Preview {
    DiaryListView(store: Store(initialState: DiaryListFeature.State()) { DiaryListFeature()
    })
}
