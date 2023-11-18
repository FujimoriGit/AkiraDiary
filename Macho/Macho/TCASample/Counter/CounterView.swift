//
//  CounterView.swift
//  Macho
//  
//  Created by Daiki Fujimori on 2023/11/18
//  
//

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
