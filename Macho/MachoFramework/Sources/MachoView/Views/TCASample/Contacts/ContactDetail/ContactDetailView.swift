//
//  ContactDetailView.swift
//  Macho
//  
//  Created by Daiki Fujimori on 2023/11/11
//  
//

import ComposableArchitecture
import SwiftUI

struct ContactDetailView: View {
    
    @Bindable var store: StoreOf<ContactDetailFeature>
    
    var body: some View {
        Form {
            Button("Delete") {
                store.send(.deleteButtonTapped)
            }
        }
        .navigationBarTitle(Text(store.contact.name))
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}

struct ContactDetailPreviews: PreviewProvider {
    
    static var previews: some View {
        NavigationStack {
            ContactDetailView(
                store: Store(
                    initialState: ContactDetailFeature.State(
                        contact: Contact(id: UUID(), name: "Blob")
                    )
                ) {
                    ContactDetailFeature()
                }
            )
        }
    }
}
