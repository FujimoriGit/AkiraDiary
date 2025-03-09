//
//  MachoFramework
//
//  SyncFocusState.swift
//
//  Created by stotic-dev on 2025/03/09
//  Copyright © Macho All rights reserved.
//

import SwiftUI

extension View {
    
    func synchronize<Value: Equatable>(
        _ first: Binding<Value>,
        _ second: FocusState<Value>.Binding
    ) -> some View {
        onChange(of: first.wrappedValue) { _, newValue in
            
            second.wrappedValue = newValue
        }
        .onChange(of: second.wrappedValue) { _, newValue in
            
            first.wrappedValue = newValue
        }
    }
}
