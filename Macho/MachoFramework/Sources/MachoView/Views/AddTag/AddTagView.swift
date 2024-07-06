//
//  AddTagView.swift
//
//  
//  Created by Daiki Fujimori on 2024/04/06
//  
//

import ComposableArchitecture
import SwiftUI

struct AddTagView: View {
    
    let store: StoreOf<AddTagFeature>
    
    var body: some View {
        NavigationStack {
            WithViewStore(store, observe: { $0 }) { viewStore in
                Form {
                    TextField("Name", text: viewStore.binding(get: \.tag.tagName, send: { .setTagName($0) }))
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
            .navigationTitle("Create Tag")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct AddTagPreviews: PreviewProvider {
    
    static var previews: some View {
        NavigationStack {
            AddTagView(store: Store(initialState: AddTagFeature.State(tag: Tag(id: UUID(), tagName: "", isSelected: true))) {
                
                AddTagFeature()
            })
        }
    }
}
