//
//  DiaryCreationView.swift
//  Macho
//  
//  Created by Daiki Fujimori on 2024/01/07
//

import ComposableArchitecture
import SwiftUI

struct DiaryCreationView: View {
    
    // MARK: - Store
    
    @Bindable private var store: StoreOf<DiaryCreationFeature>
    @State private var animationsRunning = false
    
    // MARK: - initialize
    
    init(store: StoreOf<DiaryCreationFeature>) {
        
        self.store = store
    }
    
    // MARK: - private property
    
    private let horizontalPadding: CGFloat = 16
    private let textSize: CGFloat = 16
    private let lineWidth: CGFloat = 1
    private let textEditorPadding = EdgeInsets(top: 3, leading: 5, bottom: 3, trailing: 8)
    private let placeholderPadding = EdgeInsets(top: 12, leading: 8, bottom: 8, trailing: 8)
    private let placeholderToTagsPadding: CGFloat = 12
    private let placeholderHeight: CGFloat = 200
    private let textEditorCornerRadius: CGFloat = 4
    private let tagPadding = EdgeInsets(top: 5, leading: 12, bottom: 5, trailing: 12)
    private let tagButtonsBothPadding: CGFloat = 24
    private let goalCellHeight: CGFloat = 86
    private let goalCellMargin: CGFloat = 0.5
    private let startButtonHeight: CGFloat = 48
    private let startButtonBottomPadding: CGFloat = 16
    
    private let formatter: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale.current
        
        return formatter
    }()
    
    // MARK: - body
    
    var body: some View {
        GeometryReader { geometry in
            createView(parentSize: geometry.size)
                .frame(maxWidth: geometry.size.width, minHeight: geometry.size.height)
        }
        .navigationTitle("Create Diary")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $store.scope(state: \.destination?.addGoal, action: \.destination.addGoal)) { addGoalStore in
            
            NavigationStack {
                // 次画面のインスタンス生成
                AddGoalView(store: addGoalStore)
            }
        }
        .sheet(item: $store.scope(state: \.destination?.addTag, action: \.destination.addTag)) { addTagStore in
            
            NavigationStack {
                // 次画面のインスタンス生成
                AddTagView(store: addTagStore)
            }
        }
        .onAppear {
            
            store.send(.onAppear)
        }
    }
}

// MARK: - private method

private extension DiaryCreationView {
    
    func createView(parentSize: CGSize) -> some View {
        
        VStack {
            ScrollView {
                titleTextField(parentSize: parentSize)
                
                messageTextField(parentSize: parentSize)
                
                Spacer()
                    .frame(height: placeholderToTagsPadding)
                
                tagsArea(parentSize: parentSize)
                
                Spacer()
                    .frame(height: tagButtonsBothPadding)
                
                goalsArea(parentSize: parentSize)
            }
            .scrollIndicators(.hidden)
            
            startButton(animationsRunning: store.animationsRunning, parentSize: parentSize) {
                
                store.send(.trainingStartButtonTapped)
            }
            .padding(.bottom, startButtonBottomPadding)
        }
    }
    
    func titleTextField(parentSize: CGSize) -> some View {
        VStack(alignment: .leading) {
            Text("title")
            TextField("\(formatter.string(from: Date()))", text: $store.titleText.sending(\.titleTextChange))
                .padding(8)
                .overlay(RoundedRectangle(cornerRadius: textEditorCornerRadius)
                    .stroke(Color(uiColor: .systemGray2), lineWidth: lineWidth))
        }
        .frame(width: abs(ViewUtil.calcWidth(size: parentSize, horizontalPadding: horizontalPadding) - (lineWidth * 2)))
    }
    
    func messageTextField(parentSize: CGSize) -> some View {
        VStack(alignment: .leading) {
            Text("message")
            ZStack(alignment: .topLeading) {
                TextEditor(text: $store.messageText.sending(\.messageTextChange))
                    .padding(textEditorPadding)
                    .overlay(RoundedRectangle(cornerRadius: textEditorCornerRadius)
                        .stroke(Color(uiColor: .systemGray2), lineWidth: lineWidth))
                    .frame(height: placeholderHeight)
                if store.messageText.isEmpty {
                    Text("Placeholder")
                        .foregroundColor(Color(uiColor: .placeholderText))
                        .padding(placeholderPadding)
                        .allowsHitTesting(false)
                }
            }
        }
        .frame(width: abs(ViewUtil.calcWidth(size: parentSize, horizontalPadding: horizontalPadding) - (lineWidth * 2)))
    }
    
    func tagsArea(parentSize: CGSize) -> some View {
        
        VStack(spacing: tagButtonsBothPadding) {
            addingButton(title: "Tags", parentSize: parentSize) {
                
                store.send(.tappedAddingTagButton)
            }
            
            tags { tag in
                
                store.send(.tappedTag(tag))
            } longPressAction: { tag in
                
                store.send(.longTappedTag(tag))
            }
        }
        .frame(maxWidth: ViewUtil.calcWidth(size: parentSize, horizontalPadding: horizontalPadding),
               alignment: .leading)
    }
    
    func goalsArea(parentSize: CGSize) -> some View {
        
        VStack(spacing: tagButtonsBothPadding) {
            addingButton(title: "Goals", parentSize: parentSize) {
                
                store.send(.tappedAddingGoalButton)
            }
            if store.goals.isEmpty {
                
                Text("目標を追加してください")
                    .foregroundStyle(Color(uiColor: .placeholderText))
                    .font(.system(size: 20, weight: .bold))
            }
            else {
                
                goals()
            }
        }
        .frame(maxWidth: ViewUtil.calcWidth(size: parentSize, horizontalPadding: horizontalPadding),
               minHeight: 124,
               alignment: .leading)
    }
    
    func tags(tapAction: @escaping (Tag) -> Void,
              longPressAction: @escaping (Tag) -> Void) -> some View {
        
        FlowLayout(alignment: .leading, spacing: 8) {
            ForEach(store.tags, id: \.id) { tag in
                // tapとlongPressのイベントをハンドルするため、actionでは何もしない
                Button(action: {}, label: {
                    HStack(spacing: 4) {
                        Text(tag.entity.tagName)
                            .font(.system(size: textSize, weight: tag.isSelected ? .semibold : .regular))
                        
                        Image(systemName: tag.isSelected ? "checkmark.circle.fill" : "circle.dashed")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .symbolEffect(.bounce, value: tag.isSelected)
                    }
                    .padding(tagPadding)
                    .background(tag.isSelected ? .indigo : .gray)
                    .foregroundStyle(.white)
                    .cornerRadius(14)
                    .onTapGesture {
                        
                        tapAction(tag)
                    }
                    .onLongPressGesture {
                        
                        longPressAction(tag)
                    }
                })
            }
        }
    }
    
    func goals() -> some View {
        
        List(store.goals, id: \.id) { goal in
            HStack {
                VStack(alignment: .leading) {
                    Text(goal.trainingType.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("\(goal.numberOfSets) 回, \(goal.setCount) セット")
                        .font(.system(size: 16))
                        .foregroundStyle(.white)
                }
            }
            .clipped()
            .listRowBackground(Color.indigo)
            .listRowSeparator(.hidden)
            .fixedSize(horizontal: false, vertical: true)
            .swipeActions {
                Button(role: .destructive) {
                    store.send(.deletedGoal(goal))
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                Button(action: {
                    store.send(.editingGoal(goal))
                },
                       label: {
                    Label("Edit", systemImage: "pencil")
                })
            }
        }
        .listStyle(.plain)
        .listRowSpacing(10.0)
        .scrollDisabled(true)
        .frame(minHeight: (goalCellHeight + goalCellMargin) * CGFloat(store.goals.count))
    }
    
    func addingButton(title: String, parentSize: CGSize, action: @escaping () -> Void) -> some View {
        
        HStack {
            Text(title)
            Button(action: action, label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.mint)
            })
        }
        .frame(maxWidth: ViewUtil.calcWidth(size: parentSize, horizontalPadding: horizontalPadding),
               alignment: .leading)
    }
    
    func startButton(animationsRunning: Bool,
                     parentSize: CGSize,
                     action: @escaping () -> Void) -> some View {
        
        Button(action: action, label: {
            HStack {
                Image(systemName: "figure.run.square.stack")
                    .font(.system(size: 24))
                    .symbolEffect(.bounce, value: animationsRunning)
                Text("Training Start!")
                    .font(.system(size: textSize, weight: .bold))
            }
            .frame(maxWidth: ViewUtil.calcWidth(size: parentSize, horizontalPadding: horizontalPadding),
                   minHeight: startButtonHeight)
        })
        .fillButtonStyle(backgroundColor: store.isEnableStartButton ? .orange : .gray)
        .disabled(!store.isEnableStartButton)
    }
}

// MARK: - preview

#Preview {
    DiaryCreationView(store: Store(initialState: DiaryCreationFeature.State()) {
        
        DiaryCreationFeature()
    })
}
