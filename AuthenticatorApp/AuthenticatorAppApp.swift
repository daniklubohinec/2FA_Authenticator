//
//  AuthenticatorAppApp.swift
//  AuthenticatorApp
//
//  Created by Danik Lubohinec on 20/02/2025.
//

import SwiftUI
import SwiftData

@main
struct AuthenticatorAppApp: App {
    
    @StateObject var purchaseService = PurchaseService()
    @StateObject var globalPWState = GlobalPWState()
    //    var sharedModelContainer: ModelContainer = {
    //        let schema = Schema([
    //            Item.self,
    //        ])
    //        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
    //
    //        do {
    //            return try ModelContainer(for: schema, configurations: [modelConfiguration])
    //        } catch {
    //            fatalError("Could not create ModelContainer: \(error)")
    //        }
    //    }()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(purchaseService)
                .environmentObject(globalPWState)
        }
        
        //        .modelContainer(sharedModelContainer)
    }
}


struct RootView: View {
        
    var body: some View {
        TabBarScreensView()
            .preferredColorScheme(.light)
    }
}
