//
//  TrackableList.swift
//
//
//  Created by 佐藤汰一 on 2024/04/06.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct TrackableListFeature: Reducer, Sendable {
    
    struct State: Equatable {
        
        var offset: CGFloat = .zero
        var containerSize: CGSize = .zero
        var contentSize: CGSize = .zero
        
        /// スクロール検知のバッファ値
        static private let bounceBufferValue: CGFloat = -15
        
        /// スクロール中かどうか
        var isScrolling: Bool {
            
            return offset < Self.bounceBufferValue
        }
        
        /// 下部でバウンスしているかどうか
        var isBouncedAtBottom: Bool {
            
            return isScrolling && 0 < abs(offset) + containerSize.height - contentSize.height
        }
    }
    
    enum Action: Equatable {
        
        /// スクロールした際のAction
        case onScroll(offset: CGFloat)
        /// スクロール画面が表示された際のAction
        case onAppearScrollView(container: CGSize, content: CGSize)
        /// スクロール画面のコンテンツの大きさに変更があった際のAction
        case onChangeScrollViewContentSize(container: CGSize, content: CGSize)
    }
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            
            switch action {
                
            case .onScroll(offset: let offset):
                state.offset = offset
                return .none
                
            case .onAppearScrollView(container: let container, content: let content):
                state.containerSize = container
                state.contentSize = content
                return .none
                
            case .onChangeScrollViewContentSize(container: let container, content: let content):
                state.containerSize = container
                state.contentSize = content
                return .none
            }
        }
    }
}

struct TrackableList<Content>: View where Content: View {
    
    private let store: StoreOf<TrackableListFeature>
    
    // リストのコンテンツ
    @ViewBuilder private let content: Content
    
    init(store: StoreOf<TrackableListFeature>, @ViewBuilder content: () -> Content) {
        
        self.store = store
        self.content = content()
    }
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            GeometryReader { outside in
                ScrollView {
                    LazyVStack(spacing: .zero) {
                        content
                    }
                    .background(
                        GeometryReader {
                            Color.clear.preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: $0.frame(in: .scrollView).origin.y)
                        }
                    )
                    .background {
                        GeometryReader { inside in
                            Color.clear.onChange(of: inside.size) {
                                viewStore.send(.onChangeScrollViewContentSize(container: outside.size,
                                                                              content: inside.size))
                            }
                        }
                    }
                    .background {
                        GeometryReader { inside in
                            Color.clear.onAppear {
                                viewStore.send(.onAppearScrollView(container: outside.size,
                                                                   content: inside.size))
                            }
                        }
                    }
                }
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                    viewStore.send(.onScroll(offset: offset))
                }
            }
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    
    static var defaultValue = CGFloat.zero
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        
        value += nextValue()
    }
}

#Preview {
    
    struct TrackablePreviewView: View {
        
        @State var list = [Int]()
        @State var offset = CGFloat.zero
        
        var body: some View {
            VStack(spacing: .zero) {
                Button(action: {
                    list.append((list.last ?? .zero) + 1)
                }, label: {
                    Text("Increment Button")
                })
                TrackableList(store: Store(initialState: TrackableListFeature.State(), reducer: { TrackableListFeature() })) {
                    ForEach(list, id: \.self) { index in
                        Text("index: \(index)")
                    }
                }
                Spacer()
            }
        }
    }
    
    return TrackablePreviewView()
}
