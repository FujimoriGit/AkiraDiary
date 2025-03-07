//
//  MachoApp.swift
//  Macho
//
//  Created by Daiki Fujimori on 2023/10/21.
//

import MachoFramework
import SwiftUI

@main
struct MachoApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    private var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
