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

## TCA実装ガイド

以下の動画のカウンターアプリを例に、Reducer、Viewの実装方法を示す。

https://github.com/FujimoriGit/AkiraDiary/assets/30285609/da4335a2-d9da-4842-a866-9ee6004f6b39

※ ＋-ボタンタップで上部の数値をインクリメント/デクリメントし、<br>
&emsp; factボタンタップで現在の数値に関する情報を[APIリクエスト](numbersapi.com)で取得し、表示している。

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

#Preview {
    CounterView(store: Store(initialState: CounterFeature.State()) {
        
        CounterFeature()
    })
}
```
</details>

## 画面遷移
以下の動画の連絡帳アプリを例に、画面遷移の実装方法を示す。


※ ＋-ボタンタップで上部の数値をインクリメント/デクリメントし、<br>
&emsp; factボタンタップで現在の数値に関する情報を[APIリクエスト](numbersapi.com)で取得し、表示している。

### Reducer

<details><summary>サンプルコード</summary>

```swift

```
</details>

### View

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
```
</details>

## フォルダ構成
フォルダ構成は以下にようにする。
<br>

> Macho<br>
&emsp;┗ AppControllers<br>
&emsp;&emsp; ┗ フォルダ（画面名）<br>
&emsp;&emsp;&emsp;&emsp; ┣ [画面名]Feature.swift<br>
&emsp;&emsp;&emsp;&emsp; ┗ [画面名]View.swift

## テストについて
新規機能を実装する際に、テストの実装を義務づける。<br>
テスト実装は、各機能とプレゼンテーションごと網羅するよう実装すること。<br>
詳しい実装方法は以下を参照。<br>

- [機能テスト](https://pointfreeco.github.io/swift-composable-architecture/main/tutorials/composablearchitecture/01-03-testingyourfeature)
- [プレゼンテーションテスト](https://pointfreeco.github.io/swift-composable-architecture/main/tutorials/composablearchitecture/02-03-testingpresentation/)
