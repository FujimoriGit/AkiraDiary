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
    private let filterIconSize: CGSize = .init(width: 16, height: 16)
    private let grahIconSize: CGSize = .init(width: 39, height: 39)
    
    // font property
    private let filterButtonFontSize: CGFloat = 15
    
    // padding property
    private let controlSectionPaddingHorizontal: CGFloat = 19
    
    // radius property
    private let filetrButtonRadius: CGFloat = 8

    
    var body: some View {
        NavigationStack {
            GeometryReader{ geometry in
                createMainView()
            }
            .navigationTitle("Diary List")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

private extension DiaryListView {
    
    func createMainView() -> some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                createControlSection(viewStore: viewStore)
                    .frame(height: controlSectionHeight, alignment: .bottom)
                Divider()
                Spacer()
                createListSection(viewStore: viewStore)
            }
        }
    }
    
    func createControlSection(viewStore: ViewStore<DiaryListFeature.State, DiaryListFeature.Action>) -> some View {
        HStack {
            // filterボタン
            Button(action: {
                // TODO: filter画面表示
            }, label: {
                HStack {
                    Text("filter")
                        .font(.system(size: filterButtonFontSize, weight: .regular))
                        .foregroundStyle(.white)
                    // TODO: アイコンを追加
//                    Image("", bundle: nil)
//                        .resizable()
//                        .frame(width: filterIconSize.width,
//                               height: filterIconSize.height)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .clipped()
                .background(Color.gray.clipShape(RoundedRectangle(cornerRadius: filetrButtonRadius)))
            })
            
            Spacer()
            
            // グラフボタン
            Button(action: {
                // TODO: グラフ画面への遷移
            }, label: {
                // TODO: アイコンを追加
                Image("", bundle: nil)
                    .resizable()
                    .frame(width: grahIconSize.width,
                           height: grahIconSize.height)
                    .background(Color.black.opacity(0.5))
            })
            
            // 日記新規作成ボタン
            Button(action: {
                // TODO: グラフ画面への遷移
            }, label: {
                // TODO: アイコンを追加
                Image("", bundle: nil)
                    .resizable()
                    .frame(width: grahIconSize.width,
                           height: grahIconSize.height)
                    .background(Color.black.opacity(0.5))
            })
        }
        .padding(.horizontal, controlSectionPaddingHorizontal)
    }
    
    func createListSection(viewStore: ViewStore<DiaryListFeature.State, DiaryListFeature.Action>) -> some View {
        VStack {
            ForEachStore(store.scope(state: \.diaries, action: {  .diaries(id: $0.0, action: $0.1) })) { store in
                DiaryListItemView(store: store)
            }
        }
    }
}

#Preview {
    DiaryListView(store: Store(initialState: DiaryListFeature.State()) { DiaryListFeature()
    })
}
