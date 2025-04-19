//
//  AddTagView.swift
//
//  
//  Created by Daiki Fujimori on 2024/04/06
//

import ComposableArchitecture
import SwiftUI

struct AddTagView: View {
    
    // MARK: - store
    
    @Bindable private var store: StoreOf<AddTagFeature>
    
    // MARK: - initialize
    
    init(store: StoreOf<AddTagFeature>) {
        
        self.store = store
    }
    
    // MARK: - body
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $store.tagName.sending(\.setTagName))
                    .accessibilityId(.textField("tagName"))
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
        .navigationTitle("Create Tag")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - preview

#Preview {
    NavigationStack {
        AddTagView(store: Store(initialState: AddTagFeature.State()) {
            
            AddTagFeature()
        })
    }
}
