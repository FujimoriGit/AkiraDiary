//
//  DiaryCreationView.swift
//  Macho
//  
//  Created by Daiki Fujimori on 2024/01/07
//  
//

import ComposableArchitecture
import SwiftUI

struct DiaryCreationView: View {
    
    // MARK: - Store
    
    let store: StoreOf<DiaryCreationFeature>
    @State private var animationsRunning = false
    
    // MARK: - private property
    
    private let horizontalPadding: CGFloat = 16
    private let textSize: CGFloat = 16
    private let lineWidth: CGFloat = 1
    private let textEditorPdding = EdgeInsets(top: 3, leading: 5, bottom: 3, trailing: 8)
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
            WithViewStore(store, observe: { $0 }) { viewStore in
                GeometryReader { geometry in
                    
                    // 計算を一回のみにする
                    let calculatedWidth = ViewUtil.calcWidth(size: geometry.size, horizontalPadding: horizontalPadding)
                    
                    createView(viewStore: viewStore, calculatedWidth: calculatedWidth)
                        .frame(maxWidth: geometry.size.width, minHeight: geometry.size.height)
                }
                .navigationTitle("Create Diary")
                .navigationBarTitleDisplayMode(.inline)
                .sheet(
                    store: store.scope(state: \.$destination, action: { .destination($0) }),
                    state: /DiaryCreationFeature.Destination.State.addGoal,
                    action: DiaryCreationFeature.Destination.Action.addGoal
                ) { addGoalStore in
                    
                    NavigationStack {
                        
                        // 次画面のインスタンス生成
                        AddGoalView(store: addGoalStore)
                    }
                }
                .sheet(
                    store: store.scope(state: \.$destination, action: { .destination($0) }),
                    state: /DiaryCreationFeature.Destination.State.addTag,
                    action: DiaryCreationFeature.Destination.Action.addTag
                ) { addTagStore in
                    
                    NavigationStack {
                        
                        // 次画面のインスタンス生成
                        AddTagView(store: addTagStore)
                    }
                }
                .onAppear {
                    
                    viewStore.send(.onAppear)
                }
            }
        }
    }
}

// MARK: - private method

private extension DiaryCreationView {
    
    func createView(viewStore: ViewStore<DiaryCreationFeature.State, DiaryCreationFeature.Action>,
                    calculatedWidth: CGFloat) -> some View {
        
        VStack {
            ScrollView {
                
                titleTextField(text: viewStore.binding(get: { $0.titleText },
                                                       send: DiaryCreationFeature.Action.titleTextChange),
                               calculatedWidth: calculatedWidth)
                
                messageTextField(text: viewStore.binding(get: { $0.messageText },
                                                         send: DiaryCreationFeature.Action.messageTextChange),
                                 calculatedWidth: calculatedWidth)
                
                Spacer()
                    .frame(height: placeholderToTagsPadding)
                
                tagsArea(viewStore: viewStore, calculatedWidth: calculatedWidth)
                
                Spacer()
                    .frame(height: tagButtonsBothPadding)
                
                goalsArea(viewStore: viewStore, calculatedWidth: calculatedWidth)
            }
            .scrollIndicators(.hidden)
            
            startButton(animationsRunning: viewStore.animationsRunning, calculatedWidth: calculatedWidth) {
                
                viewStore.send(.trainingStartButtonTapped)
            }
            .padding(.bottom, startButtonBottomPadding)
        }
    }
    
    func titleTextField(text: Binding<String>, calculatedWidth: CGFloat) -> some View {
        VStack(alignment: .leading) {
            Text("title")
            TextField("\(formatter.string(from: Date()))", text: text)
                .padding(8)
                .overlay(RoundedRectangle(cornerRadius: textEditorCornerRadius)
                    .stroke(Color(uiColor: .systemGray2) , lineWidth: lineWidth))
        }
        .frame(width: calculatedWidth - (lineWidth * 2))
    }
    
    func messageTextField(text: Binding<String>, calculatedWidth: CGFloat) -> some View {
        VStack(alignment: .leading) {
            Text("message")
            ZStack(alignment: .topLeading)  {
                TextEditor(text: text)
                    .padding(textEditorPdding)
                    .overlay(RoundedRectangle(cornerRadius: textEditorCornerRadius)
                        .stroke(Color(uiColor: .systemGray2), lineWidth: lineWidth))
                    .frame(height: placeholderHeight)
                if text.wrappedValue.isEmpty {
                    Text("Placeholder")
                        .foregroundColor(Color(uiColor: .placeholderText))
                        .padding(placeholderPadding)
                        .allowsHitTesting(false)
                }
            }
        }
        .frame(width: calculatedWidth - (lineWidth * 2))
    }
    
    func tagsArea(viewStore: ViewStore<DiaryCreationFeature.State, DiaryCreationFeature.Action>,
                  calculatedWidth: CGFloat) -> some View {
        
        VStack(spacing: tagButtonsBothPadding) {
            addingButton(title: "Tags", maxWidth: calculatedWidth) {
                
                viewStore.send(.tappedAddingTagButton)
            }
            
            tags(viewStore.tags) { tag in
                
                viewStore.send(.tappedTag(tag))
            }
        }
        .frame(maxWidth: calculatedWidth, alignment: .leading)
    }
    
    func goalsArea(viewStore: ViewStore<DiaryCreationFeature.State, DiaryCreationFeature.Action>,
                   calculatedWidth: CGFloat) -> some View {
        
        VStack(spacing: tagButtonsBothPadding) {
            addingButton(title: "Goals", maxWidth: calculatedWidth) {
                
                viewStore.send(.tappedAddingGoalButton)
            }
            
            goals(viewStore.goals) { goal in
                
                viewStore.send(.tappedGoal(goal))
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
                Text("Traning Start!")
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
