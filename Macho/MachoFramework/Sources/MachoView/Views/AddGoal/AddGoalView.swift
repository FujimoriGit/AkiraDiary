//
//  AddGoalView.swift
//  
//  
//  Created by Daiki Fujimori on 2024/05/03
//

import ComposableArchitecture
import SwiftUI

struct AddGoalView: View {
    
    // MARK: - store
    
    @Bindable private var store: StoreOf<AddGoalFeature>
    
    // MARK: - initialize
    
    init(store: StoreOf<AddGoalFeature>) {
        
        self.store = store
    }
    
    // MARK: - body
    
    var body: some View {
        NavigationStack {
            Form {
                menuView()
                TextField("Number Of Sets",
                          value: $store.numberOfSets.sending(\.setNumberOfSets),
                          formatter: NumberFormatter())
                TextField("Set Count",
                          value: $store.setCount.sending(\.setCount),
                          formatter: NumberFormatter())
                Button("Save") {
                    store.send(.saveButtonTapped)
                }
                .disabled(!store.isEnableSaveButton)
            }
            .toolbar {
                ToolbarItem {
                    Button("Cancel") {
                        store.send(.cancelButtonTapped)
                    }
                }
            }
            .fullScreenCover(item: $store.scope(state: \.destination, action: \.destination)) {
                
                getModalDestination($0)
                    .presentationBackground(.clear)
            }
        }
        .navigationTitle("Create Goal")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            
            store.send(.onAppear)
        }
    }
}

private extension AddGoalView {
    
    func menuView() -> some View {
        Menu {
            Section("Training Events") {
                ForEach(store.trainingTypes, id: \.id) { type in
                    Button(type.name) {
                        store.send(.selectedTrainingType(type))
                    }
                }
            }
            
            Button {
                store.send(.addingTrainingType)
            } label: {
                Label("Add to Training Events", systemImage: "plus")
            }
        } label: {
            HStack {
                Text(store.selectedTrainingType?.name ?? "select type.")
                Spacer()
                Image(systemName: "arrowtriangle.down.fill")
            }
            .foregroundStyle(Color(asset: CustomColor.appPrimaryTextColor))
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
    }
    
    func getModalDestination(_ destination: StoreOf<AddGoalFeature.Destination>) -> some View {
        
        switch destination.case {
            
        case .addTrainingType(let feature):
            return AddTrainingTypeView(store: feature)
        }
    }
}

// MARK: - preview

#Preview {
    NavigationStack {
        AddGoalView(store: Store(initialState: AddGoalFeature.State()) {
            
            AddGoalFeature()
        })
    }
}
