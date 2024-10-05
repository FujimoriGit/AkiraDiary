//
//  AddContactView.swift
//  Macho
//
//  Created by Daiki Fujimori on 2023/11/04
//
//

import ComposableArchitecture
import SwiftUI

struct AddContactView: View {
    
    @Bindable var store: StoreOf<AddContactFeature>
    
    var body: some View {
        Form {
            TextField("Name", text: $store.contact.name.sending(\.setName))
            Button("Save") {
                store.send(.saveButtonTapped)
            }
        }
        .toolbar {
            ToolbarItem {
                Button("Cancel") {
                    store.send(.cancelButtonTapped)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AddContactView(store: Store(initialState: AddContactFeature.State(contact: Contact(id: UUID(),
                                                                                           name: "Blob"))) {
            
            AddContactFeature()
        })
    }
}
