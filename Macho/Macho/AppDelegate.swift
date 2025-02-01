//
//  Macho
//
//  AppDelegate.swift
//
//  Created by stotic-dev on 2025/01/31
//  Copyright © Macho All rights reserved.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}
