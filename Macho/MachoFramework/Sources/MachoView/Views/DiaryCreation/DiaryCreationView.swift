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
        NavigationStack {
            GeometryReader { geometry in
                // 計算を一回のみにする
                let calculatedWidth = ViewUtil.calcWidth(size: geometry.size, horizontalPadding: horizontalPadding)
                
                createView(calculatedWidth: calculatedWidth)
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
}

// MARK: - private method

private extension DiaryCreationView {
    
    func createView(calculatedWidth: CGFloat) -> some View {
        
        VStack {
            ScrollView {
                titleTextField(calculatedWidth: calculatedWidth)
                
                messageTextField(calculatedWidth: calculatedWidth)
                
                Spacer()
                    .frame(height: placeholderToTagsPadding)
                
                tagsArea(calculatedWidth: calculatedWidth)
                
                Spacer()
                    .frame(height: tagButtonsBothPadding)
                
                goalsArea(calculatedWidth: calculatedWidth)
            }
            .scrollIndicators(.hidden)
            
            startButton(animationsRunning: store.animationsRunning, calculatedWidth: calculatedWidth) {
                
                store.send(.trainingStartButtonTapped)
            }
            .padding(.bottom, startButtonBottomPadding)
        }
    }
    
    func titleTextField(calculatedWidth: CGFloat) -> some View {
        VStack(alignment: .leading) {
            Text("title")
            TextField("\(formatter.string(from: Date()))", text: $store.titleText.sending(\.titleTextChange))
                .padding(8)
                .overlay(RoundedRectangle(cornerRadius: textEditorCornerRadius)
                    .stroke(Color(uiColor: .systemGray2), lineWidth: lineWidth))
        }
        .frame(width: calculatedWidth - (lineWidth * 2))
    }
    
    func messageTextField(calculatedWidth: CGFloat) -> some View {
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
        .frame(width: calculatedWidth - (lineWidth * 2))
    }
    
    func tagsArea(calculatedWidth: CGFloat) -> some View {
        
        VStack(spacing: tagButtonsBothPadding) {
            addingButton(title: "Tags", maxWidth: calculatedWidth) {
                
                store.send(.tappedAddingTagButton)
            }
            
            tags(store.tags) { tag in
                
                store.send(.tappedTag(tag))
            }
        }
        .frame(maxWidth: calculatedWidth, alignment: .leading)
    }
    
    func goalsArea(calculatedWidth: CGFloat) -> some View {
        
        VStack(spacing: tagButtonsBothPadding) {
            addingButton(title: "Goals", maxWidth: calculatedWidth) {
                
                store.send(.tappedAddingGoalButton)
            }
            
            goals(store.goals) { goal in
                
                store.send(.tappedGoal(goal))
            }
        }
        .frame(maxWidth: calculatedWidth, alignment: .leading)
    }
    
    func tags(_ tags: [Tag], action: @escaping (Tag) -> Void) -> some View {
        
        FlowLayout(alignment: .leading, spacing: 8) {
            ForEach(tags, id: \.id) { tag in
                Button(action: {
                    action(tag)
                }, label: {
                    HStack(spacing: 4) {
                        Text(tag.tagName)
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
                })
            }
        }
    }
    
    func goals(_ goals: [Goal], action: @escaping (Goal) -> Void) -> some View {
        
        VStack {
            ForEach(goals, id: \.id) { goal in
                Button {
                    action(goal)
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(goal.goalName)
                            Text("\(goal.numberOfSets) 回, \(goal.setCount) セット")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        
                        Image(systemName: goal.isSelected ? "checkmark.circle.fill" : "circle.dashed")
                            .foregroundStyle(.white)
                            .font(.system(size: 24, weight: goal.isSelected ? .semibold : .regular))
                            .contentTransition(.symbolEffect)
                            .animation(.linear, value: goal.isSelected)
                            .padding(.trailing, 12)
                    }
                    .contentShape(Rectangle())
                    .frame(maxWidth: .infinity, minHeight: 48)
                }
                .fillButtonStyle(foregroundColor: .white,
                                 backgroundColor: goal.isSelected ? .indigo : .gray,
                                 pressedBackgroundColor: .indigo.opacity(0.5))
            }
        }
    }
    
    func addingButton(title: String, maxWidth: CGFloat, action: @escaping () -> Void) -> some View {
        
        HStack {
            Text(title)
            Button(action: action, label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.mint)
            })
        }
        .frame(maxWidth: maxWidth, alignment: .leading)
    }
    
    func startButton(animationsRunning: Bool, calculatedWidth: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action, label: {
            HStack {
                Image(systemName: "figure.run.square.stack")
                    .font(.system(size: 24))
                    .symbolEffect(.bounce, value: animationsRunning)
                Text("Training Start!")
                    .font(.system(size: textSize, weight: .bold))
            }
            .frame(maxWidth: calculatedWidth, minHeight: startButtonHeight)
        })
        .fillButtonStyle(backgroundColor: .orange)
    }
}

// MARK: - preview

#Preview {
    DiaryCreationView(store: Store(initialState: DiaryCreationFeature.State()) {
        
        DiaryCreationFeature()
    })
}
