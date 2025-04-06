//
//  AuthenticatorAppApp.swift
//  AuthenticatorApp
//
//  Created by Gideon Thackery on 20/02/2025.
//

import SwiftUI

@main
struct AuthenticatorAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var purchaseService = PurchaseService()
    @StateObject private var globalPWState = GlobalPWState()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(purchaseService)
                .environmentObject(globalPWState)
                .edgesIgnoringSafeArea(.vertical)
        }
    }
}
