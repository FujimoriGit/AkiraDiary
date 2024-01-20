//
//  ContactsView.swift
//  Macho
//  
//  Created by Daiki Fujimori on 2023/11/04
//  
//

import ComposableArchitecture
import RealmHelper
import SwiftUI

struct ContactsView: View {
    
    let store: StoreOf<ContactsFeature>
    let entity = DiarySearchTagEntity(id: UUID(), tagName: "")
    
    var body: some View {
        // Push遷移の場合、NavigationStackStoreでラップ.
        NavigationStackStore(store.scope(state: \.path, action: { .path($0) })) {
            WithViewStore(store, observe: \.contacts) { viewStore in
                List {
                    ForEach(viewStore.state) { contact in
                        NavigationLink(state: ContactDetailFeature.State(contact: contact)) {
                            HStack {
                                Text(contact.name)
                                Spacer()
                                Button {
                                    viewStore.send(.deleteButtonTapped(id: contact.id))
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
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
                            viewStore.send(.addButtonTapped)
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        } destination: { store in
            
            ContactDetailView(store: store)
        }
        // Modal遷移の場合、sheetのmodifierを使用.
        .sheet(
            store: store.scope(state: \.$destination, action: { .destination($0) }),
            state: /ContactsFeature.Destination.State.addContact,
            action: ContactsFeature.Destination.Action.addContact
        ) { addContactStore in
            
            NavigationStack {
                // 次画面のインスタンス生成
                AddContactView(store: addContactStore)
            }
        }
        // Alert表示の場合、alertのmodifierを使用.
        .alert(
            store: store.scope(state: \.$destination, action: { .destination($0) }),
            state: /ContactsFeature.Destination.State.alert,
            action: ContactsFeature.Destination.Action.alert
        )
    }
}

struct ContactsView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContactsView(
            store: Store(initialState: ContactsFeature.State(
                contacts: [Contact(id: UUID(), name: "Blob"),
                           Contact(id: UUID(), name: "Blob Jr"),
                           Contact(id: UUID(), name: "Blob Sr"),])) {
                               
                               ContactsFeature()
                           }
        )
    }
}
