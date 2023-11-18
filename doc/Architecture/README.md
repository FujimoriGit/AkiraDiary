# アーキテクチャについて

## 概要
本プロジェクトでは、[The Composable Architecture（TCA）](https://github.com/pointfreeco/swift-composable-architecture)を採用する。<br>
TCAの仕様と、本プロジェクトでのコーディングルールについて示す。

## TCAについて
TCAを構成する要素一覧を以下に示す。<br>

- **State** : 機能がロジックを実行し、UIをレンダリングするために必要なデータを記述するタイプ。
- **Action** : ユーザーアクション、通知、イベントソースなど、機能内で発生する可能性のあるすべてのアクションを表すタイプ。
- **Reducer** : アクションが与えられた場合に、アプリの現在の状態を次の状態に進化させる方法を記述する関数。Reducerは、値を返すことによって実行できる APIリクエストなど、実行する必要があるEffectを返す責任もある。
- **Store** : 実際に機能を駆動するランタイム。すべてのユーザーアクションをStoreに送信すると、StoreでReducerとEffectを実行できるようになり、Store内の状態の変化を観察してUIを更新できる。

## フォルダ構成
フォルダ構成は以下にようにする。
<br>

> Macho<br>
&emsp;┗ AppControllers（フォルダ）<br>
&emsp;&emsp; ┗ [画面名]（フォルダ）<br>
&emsp;&emsp;&emsp;&emsp; ┣ [画面名]Feature.swift<br>
&emsp;&emsp;&emsp;&emsp; ┗ [画面名]View.swift

## ビジネスロジック

以下の動画のカウンターアプリを例に、ビジネスロジックの実装方法を示す。

https://github.com/FujimoriGit/AkiraDiary/assets/30285609/da4335a2-d9da-4842-a866-9ee6004f6b39

※ ＋-ボタンタップで上部の数値をインクリメント/デクリメントし、<br>
&emsp; factボタンタップで現在の数値に関する情報を[APIリクエスト](http://www.numbersapi.com)で取得し、表示している。

### Reducer

<details><summary>サンプルコード</summary>


```swift
import ComposableArchitecture
import Foundation

struct CounterFeature: Reducer {
    
    // MARK: - State

    // 画面の状態を表す. ViewModel的な役割.
    struct State: Equatable {
        
        var count = 0
        var fact: String?
        var isLoading = false
    }
    
    // MARK: - Action
    
    // 画面で発生する可能性のあるすべてのアクションを表す.
    // 各アクションは、イベント名を記載すること.
    enum Action: Equatable {
        
        /// インクリメントボタンタップ時
        case incrementButtonTapped
        /// デクリメントボタンタップ時
        case decrementButtonTapped
        /// factボタン押下時
        case factButtonTapped
        /// factレスポンス返却時
        case factResponse(String)
    }
    
    // MARK: - body
    
    /// Reducerのロジック部分. bodyで記載すること.
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            
            switch action {
                
            case .incrementButtonTapped:
                // [同期処理] 受信したActionによってStateの更新を行う.
                state.count += 1
                state.fact = nil
                return .none
                
            case .decrementButtonTapped:
                // [同期処理] 受信したActionによってStateの更新を行う.
                state.count -= 1
                state.fact = nil
                return .none
                
            case .factButtonTapped:
                state.fact = nil
                state.isLoading = true
                // APIリクエスト等非同期処理を行う際には.runを使用する.
                return .run { [count = state.count] send in
                    
                    let (data, _) = try await URLSession.shared
                        .data(from: URL(string: "http://numbersapi.com/\(count)")!)
                    let fact = String(decoding: data, as: UTF8.self)
                    
                    // [非同期処理] ↓ここでstate更新は禁止されており、ビルドエラーとなる.
                    // 　　　　　　　state.fact = fact
                    // 　　　　　　　そのため、非同期処理終了のActionをSendする.
                    await send(.factResponse(fact))
                }
                
            case .factResponse(let fact):
                // [非同期処理] ↓ここで初めてstateの更新が可能となる.
                state.fact = fact
                state.isLoading = false
                return .none
            }
        }
    }
}

```
</details>

### View

<details><summary>サンプルコード</summary>

```swift
import ComposableArchitecture
import SwiftUI

struct CounterView: View {
    
    // MARK: - Store
    
    let store: StoreOf<CounterFeature>
    
    // MARK: - body
    
    var body: some View {
        // Stateを監視するため、WithViewStoreでラップする.
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                Text("\(viewStore.count)")
                    .font(.largeTitle)
                    .padding()
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(10)
                HStack {
                    Button("-") {
                        // アクションをsend
                        viewStore.send(.decrementButtonTapped)
                    }
                    .font(.largeTitle)
                    .padding()
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(10)
                    
                    Button("+") {
                        // アクションをsend
                        viewStore.send(.incrementButtonTapped)
                    }
                    .font(.largeTitle)
                    .padding()
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(10)
                    
                    Button("Fact") {
                        // アクションをsend
                        viewStore.send(.factButtonTapped)
                    }
                    .font(.largeTitle)
                    .padding()
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(10)
                    
                    if viewStore.isLoading {
                        
                      ProgressView()
                    }
                    else if let fact = viewStore.fact {
                        
                      Text(fact)
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                        .padding()
                    }
                }
            }
        }
    }
}
```
</details>

## 画面遷移
以下の動画の連絡帳アプリを例に、画面遷移の実装方法を示す。


### Reducer（遷移元）

<details><summary>サンプルコード</summary>

```swift
import ComposableArchitecture
import Foundation

struct Contact: Equatable, Identifiable {
    
    let id: UUID
    var name: String
}

struct ContactsFeature: Reducer {
    
    // MARK - State

    struct State: Equatable {
        
        var contacts: IdentifiedArrayOf<Contact> = []
        // modal(present)にて遷移を行う際に使用するプロパティラッパー @PresentationState
        // presentのため、双方向バインディングを行える仕組みになっている.
        // nilは子ビューが表示されないことを表し、nil以外の場合は表示されることを表します.
        @PresentationState var destination: Destination.State?
        var path = StackState<ContactDetailFeature.State>()
    }
    
    // MARK - Action

    enum Action: Equatable {
        
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
                // 遷移時の子ビューにcontactを注入
                state.destination = .addContact(
                    AddContactFeature.State(
                        contact: Contact(id: self.uuid(), name: "")
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
                // alert表示要求
                state.destination = .alert(.deleteConfirmation(id: id))
                return .none
                
            case let .path(.element(id: id, action: .delegate(.confirmDeletion))):
                guard let detailState = state.path[id: id]
                else { return .none }
                state.contacts.remove(id: detailState.contact.id)
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

// Destinationの実装は、extensionブロックで行ってください.
extension ContactsFeature {
    
    // Reducer（ContactsFeature）内にネストされたDestinationという名前の新しいReducerを定義します.
    // このReducerは、プレゼンテーションロジックを保持します.
    struct Destination: Reducer {
        
        // MARK - State

        enum State: Equatable {
            
            case addContact(AddContactFeature.State)
            case alert(AlertState<ContactsFeature.Action.Alert>)
        }
        
        // MARK - Action

        enum Action: Equatable {
            
            case addContact(AddContactFeature.Action)
            case alert(ContactsFeature.Action.Alert)
        }

        // MARK - body

        var body: some ReducerOf<Self> {
            
            // 遷移する子ビューをScopeを使用して定義する.
            // https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/scope/
            // state: 親ステート内の子ステートを識別する書き込み可能なキーパス
            // action: 親アクション内の子アクションを識別するケースパス
            Scope(state: /State.addContact, action: /Action.addContact) {
                
                // 子ビューで実行するReducer 
                AddContactFeature()
            }
        }
    }
}
```
</details>

### View（遷移元）

<details><summary>サンプルコード</summary>

```swift
struct ContactsView: View {
    
    let store: StoreOf<ContactsFeature>
    
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
                // 遷移先Viewのインスタンス生成.
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
```
</details>

画面遷移について、詳細は以下を参照。<br>
[初めてのプレゼンテーション](https://pointfreeco.github.io/swift-composable-architecture/main/tutorials/composablearchitecture/02-01-yourfirstpresentation)

## テストについて
新規機能を実装する際に、テストの実装を義務づける。<br>
テスト実装は、各機能とプレゼンテーションごと網羅するよう実装すること。<br>
詳しい実装方法は以下を参照。<br>

- [機能テスト](https://pointfreeco.github.io/swift-composable-architecture/main/tutorials/composablearchitecture/01-03-testingyourfeature)
- [プレゼンテーションテスト](https://pointfreeco.github.io/swift-composable-architecture/main/tutorials/composablearchitecture/02-03-testingpresentation/)
