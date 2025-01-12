//
//  AddTrainingTypeView.swift
//  MachoFramework
//  
//  Created by Daiki Fujimori on 2024/11/30
//  

import ComposableArchitecture
import SwiftUI

struct AddTrainingTypeView: View {
    
    // MARK: - store
    
    @Bindable private var store: StoreOf<AddTrainingTypeFeature>
    
    // MARK: - initialize
    
    init(store: StoreOf<AddTrainingTypeFeature>) {
        
        self.store = store
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Event Name",
                          text: $store.name.sending(\.setName))
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
        }
        .navigationTitle("Create Training Event")
        .navigationBarTitleDisplayMode(.inline)
    }
}
