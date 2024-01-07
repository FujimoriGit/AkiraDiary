//
//  ContactsFeature.swift
//  Macho
//  
//  Created by Daiki Fujimori on 2023/11/04
//  
//

import ComposableArchitecture
import Foundation

struct Contact: Equatable, Identifiable {
    
    let id: UUID
    var name: String
}

struct ContactsFeature: Reducer {
    
    struct State: Equatable {
        
        var contacts: IdentifiedArrayOf<Contact> = []
        @PresentationState var destination: Destination.State?
        var path = StackState<ContactDetailFeature.State>()
    }
    
    enum Action {
        
        case addButtonTapped
        case deleteButtonTapped(id: Contact.ID)
        case destination(PresentationAction<Destination.Action>)
        case path(StackAction<ContactDetailFeature.State, ContactDetailFeature.Action>)
        
        enum Alert: Equatable {
            
            case confirmDeletion(id: Contact.ID)
        }
    }
    
    @Dependency(\.uuid) var uuid
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            
            switch action {
                
            case .addButtonTapped:
                state.destination = .addContact(
                    AddContactFeature.State(
                        contact: Contact(id: uuid(), name: "")
                    )
                )
                return .none
                
            case let .destination(.presented(.addContact(.delegate(.saveContact(contact))))):
                state.contacts.append(contact)
                return .none
                
            case let .destination(.presented(.alert(.confirmDeletion(id: id)))):
                state.contacts.remove(id: id)
                return .none
                
            case let .deleteButtonTapped(id: id):
                state.destination = .alert(.deleteConfirmation(id: id))
                return .none
                
            case let .path(.element(id: id, action: .delegate(.confirmDeletion))):
                guard let detailState = state.path[id: id]
                else { return .none }
                state.contacts.remove(id: detailState.contact.id)
                return .none
                
            case .path:
                return .none
                
            case .destination(.dismiss):
                return .none
                
            case .destination(.presented(.addContact(.cancelButtonTapped))):
                return .none
                
            case .destination(.presented(.addContact(.saveButtonTapped))):
                return .none
                
            case .destination(.presented(.addContact(.setName(_)))):
                return .none
            }
        }
        // Modal遷移を実装する場合、ifLet関数を使用し、Destinationから遷移を要求する
        .ifLet(\.$destination, action: /Action.destination) {
            
            Destination()
        }
        // Push遷移を実装する場合forEach関数を使用し、直接遷移を実施する
        .forEach(\.path, action: /Action.path) {
            
            // 遷移先画面のReducerを生成する
            ContactDetailFeature()
        }
    }
}

extension ContactsFeature {
    
    struct Destination: Reducer {
        
        enum State: Equatable {
            
            case addContact(AddContactFeature.State)
            case alert(AlertState<ContactsFeature.Action.Alert>)
        }
        
        enum Action: Equatable {
            
            case addContact(AddContactFeature.Action)
            case alert(ContactsFeature.Action.Alert)
        }
        var body: some ReducerOf<Self> {
            
            // 遷移する子ビューをScopeを使用して定義する.
            // https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/scope/
            // state: 親ステート内の子ステートを識別する書き込み可能なキーパス
            // action: 親アクション内の子アクションを識別するケースパス
            Scope(state: /State.addContact, action: /Action.addContact) {
                
                AddContactFeature()
            }
        }
    }
}

extension AlertState where Action == ContactsFeature.Action.Alert {
    
    static func deleteConfirmation(id: UUID) -> Self {
        
        Self {
            
            TextState("Are you sure?")
        } actions: {
            
            ButtonState(role: .destructive, action: .confirmDeletion(id: id)) {
                TextState("Delete")
            }
        }
    }
}
