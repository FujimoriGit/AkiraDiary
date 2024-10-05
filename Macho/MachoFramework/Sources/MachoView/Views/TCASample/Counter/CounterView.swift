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
    
    @Bindable var store: StoreOf<CounterFeature>
    
    // MARK: - body
    
    var body: some View {
        VStack {
            Text("\(store.count)")
                .font(.largeTitle)
                .padding()
                .background(Color.black.opacity(0.1))
                .cornerRadius(10)
            HStack {
                Button("-") {
                    // アクションをsend
                    store.send(.decrementButtonTapped)
                }
                .font(.largeTitle)
                .padding()
                .background(Color.black.opacity(0.1))
                .cornerRadius(10)
                
                Button("+") {
                    // アクションをsend
                    store.send(.incrementButtonTapped)
                }
                .font(.largeTitle)
                .padding()
                .background(Color.black.opacity(0.1))
                .cornerRadius(10)
                
                Button("Fact") {
                    // アクションをsend
                    store.send(.factButtonTapped)
                }
                .font(.largeTitle)
                .padding()
                .background(Color.black.opacity(0.1))
                .cornerRadius(10)
                
                if store.isLoading {
                    
                  ProgressView()
                }
                else if let fact = store.fact {
                    
                  Text(fact)
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .padding()
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
