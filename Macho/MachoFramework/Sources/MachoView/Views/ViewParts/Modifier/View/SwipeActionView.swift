//
//  SwipeActionView.swift
//
//
//  Created by 佐藤汰一 on 2024/04/13.
//

import SwiftUI

extension View {
    
    /// 横スワイプ時のアクションを追加する
    /// - Parameters:
    ///   - direction: スワイプする方向
    ///   - cornerRadius: スワイプ対象のCornerRadius値
    ///   - actions: スワイプ時に表示するアクションボタンの設定
    func addSwipeAction(direction: SwipeDirection = .trailing,
                        cornerRadius: CGFloat = .zero,
                        @ActionBuilder _ actions: () -> [SwipeAction]) -> some View {
        
        SwipeActionView(direction: direction, cornerRadius: cornerRadius, actions: actions()) {
            self
        }
    }
}

struct SwipeActionView<Content>: View where Content: View {
    
    /// スワイプの方向
    var direction: SwipeDirection = .trailing
    /// スワイプ対象のセルの角丸設定
    var cornerRadius: CGFloat
    /// スワイプ時に表示するボタンのリスト
    var actions: [SwipeAction]
    /// スワイプアクションを追加する対象のView
    @ViewBuilder var content: Content
    /// ViewのID
    private let viewId = UUID()
    
    init(direction: SwipeDirection,
         cornerRadius: CGFloat,
         actions: [SwipeAction],
         @ViewBuilder content: () -> Content) {
        
        self.direction = direction
        self.cornerRadius = cornerRadius
        self.actions = actions
        self.content = content()
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                LazyHStack(spacing: .zero) {
                    content
                        .containerRelativeFrame(.horizontal)
                        .background {
                            if let firstAction = actions.first {
                                Rectangle()
                                    .foregroundStyle(firstAction.tint)
                            }
                        }
                        .id(viewId)
                        .transition(.identity)
                    createButtons {
                        withAnimation(.snappy) {
                            proxy.scrollTo(viewId,
                                           anchor: direction == .trailing ? .topLeading : .topTrailing)
                        }
                    }
                }
                .scrollTargetLayout()
                .visualEffect { content, geometryProxy in
                    content
                        .offset(x: scrollOffset(geometryProxy))
                }
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .background {
                if let lastAction = actions.last {
                    Rectangle()
                        .foregroundStyle(lastAction.tint)
                }
            }
            .clipShape(.rect(cornerRadius: cornerRadius))
        }
        .transition(.slide)
    }
}

private extension SwipeActionView {
    
    func createButtons(resetPositionTask: @escaping () -> Void) -> some View {
        Rectangle()
            .fill(.clear)
            .frame(width: CGFloat(actions.count) * 100)
            .overlay(alignment: direction.alignment) {
                HStack(spacing: .zero) {
                    ForEach(actions, id: \.id) { actionModel in
                        Button(action: {
                            Task {
                                // 非同期で初期位置に戻る
                                resetPositionTask()
                            }
                            // 設定しているActionを実行
                            actionModel.action()
                        }) {
                            actionModel.icon
                                .font(.title)
                                .foregroundStyle(actionModel.iconTint)
                                .frame(width: 100)
                                .frame(maxHeight: .infinity)
                                .clipShape(.rect)
                        }
                        .background(actionModel.tint)
                    }
                }
            }
    }
    
    func scrollOffset(_ proxy: GeometryProxy) -> CGFloat {
        
        let minX = proxy.frame(in: .scrollView(axis: .horizontal)).minX
        return direction == .trailing ? (minX > 0 ? -minX : 0) : (minX < 0 ? -minX : 0)
    }
}

/// スワイプ出来る方向
enum SwipeDirection {
    
    case leading
    case trailing
    
    var alignment: Alignment {
        
        switch self {
            
        case .leading: .leading
            
        case .trailing: .trailing
        }
    }
}

struct SwipeAction: Identifiable {
    
    private(set) var id: UUID = .init()
    /// ボタンの色
    let tint: Color
    /// ボタンのアイコン
    let icon: Image
    /// アイコンの色
    let iconTint = Color(asset: CustomColor.swipeActionIconForegroundColor)
    /// ボタンのアクション
    let action: () -> Void
}

/// 複数のスワイプ時のアクションを配列にビルドするresultBuilder
@resultBuilder
struct ActionBuilder {
    
    static func buildBlock(_ components: SwipeAction...) -> [SwipeAction] {
        return components
    }
}

// MARK: - preview

#Preview {
    
    return SwipeSampleView()
}

struct SwipeSampleView: View {
    
    @State private var colors: [Color] = [.red, .blue, .yellow, .brown]
    
    var body: some View {
        Button(action: {
            withAnimation {
                colors = [.red, .blue, .yellow, .brown]
            }
        }, label: {
            Text("Clear")
                .frame(height: 100)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.white)
                .background(.black)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal, 12)
                .font(.system(size: 24, weight: .bold))
        })
        ScrollView {
            ForEach(colors, id: \.self) { color in
                CardView(color: color)
                    .addSwipeAction(direction: .trailing,
                                    cornerRadius: 8) {
                        SwipeAction(tint: .blue,
                                    icon: Image(systemName: "star.fill")) {
                            print("Edit.")
                        }
                        SwipeAction(tint: Color(asset: CustomColor.deleteSwipeBackgroundColor),
                                    icon: Image(systemName: "trash.fill")) {
                            print("delete.")
                            withAnimation {
                                colors.removeAll { $0 == color }
                            }
                        }
                    }
                                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 10)
        }
    }
}

struct CardView: View {
    
    let color: Color
    
    var body: some View {
        HStack(spacing: .zero) {
            Circle()
                .frame(width: 50, height: 50)
                .foregroundStyle(.black)
            Spacer()
                .frame(width: 10)
            VStack(alignment: .leading) {
                Rectangle()
                    .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: 10)
                    .foregroundStyle(.black.opacity(0.4))
                Rectangle()
                    .frame(width: 200, height: 10)
                    .foregroundStyle(.black.opacity(0.4))
            }
            Spacer()
        }
        .padding(18)
        .foregroundStyle(.white)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
