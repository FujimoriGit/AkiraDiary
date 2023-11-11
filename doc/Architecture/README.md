# アーキテクチャについて

## 概要
本プロジェクトでは、[The Composable Architecture（TCA）](https://github.com/pointfreeco/swift-composable-architecture)を採用する。<br>
TCAの仕様と、本プロジェクトでのコーディングルールについて示す。

## TCAについて
TCAを構成する要素一覧を以下に示す。<br>

- **State** : 機能がロジックを実行し、UIをレンダリングするために必要なデータを記述するタイプ。Reducer protocolのrequired property。
- **Action** : ユーザーアクション、通知、イベントソースなど、機能内で発生する可能性のあるすべてのアクションを表すタイプ。Reducer protocolのrequired property。
- **Reducer** : アクションが与えられた場合に、アプリの現在の状態を次の状態に進化させる方法を記述する関数。Reducerは、値を返すことによって実行できる APIリクエストなど、実行する必要があるEffectを返す責任もある。
- **Store** : 実際に機能を駆動するランタイム。すべてのユーザーアクションをStoreに送信すると、StoreでReducerとEffectを実行できるようになり、Store内の状態の変化を観察してUIを更新できる。

以下の動画のカウンターアプリを例に、ビジネスロジック、Viewの説明を示す。

https://github.com/FujimoriGit/AkiraDiary/assets/30285609/da4335a2-d9da-4842-a866-9ee6004f6b39

### ビジネスロジック

<details><summary>サンプルコード</summary>


```swift
import ComposableArchitecture
import Foundation



struct CounterFeature: Reducer {
    
    // MARK: State
    
    struct State: Equatable {
        
        var count = 0
        var fact: String?
        var isLoading = false
    }
    
    // MARK: - Action
    
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

```
</details>

## 画面遷移
以下サンプルコードに倣い、各Reducerクラスのextensionに記載する。
<details><summary>サンプルコード</summary>


```swift
// MARK: - extension (for presentation)

extension ContactsFeature {
    
    // 命名は「Destination」に統一。
    struct Destination: Reducer {
        
        enum State: Equatable {
            
            case addContact(AddContactFeature.State)
            case alert(AlertState<ContactsFeature.Action.Alert>)
            case top
        }
        
        enum Action: Equatable {
            
            case addContact(AddContactFeature.Action)
            case alert(ContactsFeature.Action.Alert)
            case top
        }
        
        var body: some ReducerOf<Self> {
            
            Scope(state: /State.addContact, action: /Action.addContact) {

                // 遷移
                AddContactFeature()
            }
            
            Scope(state: /State.top, action: /Action.top) {
                
                
            }
        }
    }
}
```
</details>

## フォルダ構成
フォルダ構成は以下にようにする。
<br>

> Macho<br>
&emsp;└ AppControllers<br>
&emsp;&emsp; └ フォルダ（画面名）<br>
&emsp;&emsp;&emsp;&emsp; ├ [画面名]Feature.swift<br>
&emsp;&emsp;&emsp;&emsp; └ [画面名]View.swift

## テストについて
新規機能を実装する際に、テストの実装を義務づける。<br>
テスト実装は、各機能とプレゼンテーションごと網羅するよう実装すること。<br>
詳しい実装方法は以下を参照。<br>

- [機能テスト](https://pointfreeco.github.io/swift-composable-architecture/main/tutorials/composablearchitecture/01-03-testingyourfeature)
- [プレゼンテーションテスト](https://pointfreeco.github.io/swift-composable-architecture/main/tutorials/composablearchitecture/02-03-testingpresentation/)
