//
//  ContactsView.swift
//  Macho
//
//  Created by Daiki Fujimori on 2023/11/04
//
//

import ComposableArchitecture
import SwiftUI

struct ContactsView: View {
    
    @Bindable var store: StoreOf<ContactsFeature>
    
    var body: some View {
        // Push遷移の場合、NavigationStackでラップ.
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            List {
                ForEach(store.contacts) { contact in
                    NavigationLink(state: ContactDetailFeature.State(contact: contact)) {
                        HStack {
                            Text(contact.name)
                            Spacer()
                            Button {
                                store.send(.deleteButtonTapped(id: contact.id))
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                    .accessibilityHidden(true)
                            }
                        }
                    }
                    .buttonStyle(.borderless)
                }
            }
            .navigationTitle("Contacts")
            .toolbar {
                ToolbarItem {
                    Button {
                        store.send(.addButtonTapped)
                    } label: {
                        Image(systemName: "plus")
                            .accessibilityHidden(true)
                    }
                }
            }
        } destination: {
            ContactDetailView(store: $0)
        }
        // Modal遷移の場合、sheetのmodifierを使用.
        .sheet(item: $store.scope(state: \.destination?.addContact, action: \.destination.addContact)) { store in
            
            NavigationStack {
                // 次画面のインスタンス生成
                AddContactView(store: store)
            }
        }
        // Alert表示の場合、alertのmodifierを使用.
        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
    }
}

struct ContactsView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContactsView(
            store: Store(initialState: ContactsFeature.State(
                contacts: [
                    Contact(id: UUID(), name: "Blob"),
                    Contact(id: UUID(), name: "Blob Jr"),
                    Contact(id: UUID(), name: "Blob Sr")
                ])) {
                               
                ContactsFeature()
            }
        )
    }
}
