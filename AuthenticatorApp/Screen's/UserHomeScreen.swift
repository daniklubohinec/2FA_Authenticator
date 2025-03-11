//
//  UserHomeScreen.swift
//  AuthenticatorApp
//
//  Created by Danik Lubohinec on 25/02/2025.
//

import SwiftUI

struct UserHomeScreen: View {
    
    @State private var isPaywallPresented = false
    @StateObject var appStateManager = AppStateManager()
    
    var body: some View {
        VStack {
            Text("Authenticator")
                .padding(.top, 28)
                .font(.bold(size: 26))
                .foregroundStyle(.c090A36)
            
            HStack {
                Button(action: {
                    EfficinacyCaller.shared.callHaptic()
                }) {
                    Image("sdklgsdfsdfd")
                }
                
                Button(action: {
                    EfficinacyCaller.shared.callHaptic()
                    print("Button Pressed")
                    isPaywallPresented.toggle()
                }) {
                    Image("ashfahfasjfa")
                }
                //                .fullScreenCover(isPresented: $isPresented, content: PaywallScreen.init)
                .fullScreenCover(isPresented: $isPaywallPresented) {
                    // safe unwrap, because there is check on line 73
                    //                    if let pw = purchaseManager.inAppPaywall {
                    PaywallScreen(appState: appStateManager)
                    //                    }
                }
            }
            Spacer()
            // Empty State Illustration
            Image(.ghjfhahdfasdas)
                .padding(.bottom, 90)
            
            Spacer()
        }
    }
}

#Preview {
    UserHomeScreen()
}
