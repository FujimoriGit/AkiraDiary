//
//  AddGoalView.swift
//  
//  
//  Created by Daiki Fujimori on 2024/05/03
//  
//

import ComposableArchitecture
import SwiftUI

struct AddGoalView: View {
    
    let store: StoreOf<AddGoalFeature>
    
    var body: some View {
        NavigationStack {
            WithViewStore(store, observe: { $0 }) { viewStore in
                Form {
                    TextField("Name", text: viewStore.binding(get: \.goal.goalName, send: { .setGoalName($0) }))
                    TextField("Number Of Sets", value: viewStore.binding(get: \.goal.numberOfSets, send: { .setNumberOfSets($0) }), formatter: NumberFormatter())
                    TextField("Set Count", value: viewStore.binding(get: \.goal.setCount, send: { .setCount($0) }), formatter: NumberFormatter())
                    Button("Save") {
                        viewStore.send(.saveButtonTapped)
                    }
                    .disabled(!viewStore.isEnableSaveButton)
                }
                .toolbar {
                    ToolbarItem {
                        Button("Cancel") {
                            viewStore.send(.cancelButtonTapped)
                        }
                    }
                }
            }
            .navigationTitle("Create Goal")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct AddGoalPreviews: PreviewProvider {
    
    static var previews: some View {
        NavigationStack {
            AddGoalView(store: Store(initialState: AddGoalFeature.State(goal: Goal(id: UUID(), goalName: "", numberOfSets: 0, setCount: 0))){
                
                AddGoalFeature()
            })
        }
    }
}

