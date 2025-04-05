//
//  UserSettingsScreen.swift
//  AuthenticatorApp
//
//  Created by Gideon Thackery on 25/02/2025.
//

import SwiftUI
import MessageUI
import LocalAuthentication

struct UserSettingsScreen: View {
    
    @ObservedObject var appState: AppStateManager
    @Environment(\.openURL) var openUrl
    
    @EnvironmentObject var purchaseService: PurchaseService
    @State var showNoRestoreAlert = false
    @State var showActiveSubscriptionAlert = false
    @State var showAlert = false
    
    var body: some View {
        VStack {
            Text("Settings")
                .padding(.top, 28)
                .padding(.bottom, -10)
                .font(.bold(size: 26))
                .foregroundStyle(.c090A36)
            ScrollView {
                ToggleRow(title: "Face ID", isEnabled: false)
                    .padding(.top, 10)
                    .padding(.bottom, 5)
                
                SettingsButton(icon: "gwjehrfhjefd", title: "Feedback") { feedbackButtonPressed() }
                SettingsButton(icon: "erhjgfdsjfk", title: "Rate Us") { appState.showRequestReview() }
                SettingsButton(icon: "rheijrsdgfsdfsd", title: "Share") { shareButtonPressed() }
                SettingsButton(icon: "rehijwfgdfaf", title: "Privacy Policy") { privacyPolicyButtonPressed() }
                SettingsButton(icon: "rhijwjgfdafafa", title: "Terms of use") { termsOfUseButtonPressed() }
                SettingsButton(icon: "bhwejugfwef", title: "Restore") { restoreButtonPresses() }
                Spacer()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Cannot Send Mail"),
                  message: Text("Please configure an email account in the Mail app to send email."),
                  dismissButton: .default(Text("OK")))
        }
        .alert("Error", isPresented: $showNoRestoreAlert) {
            Button {
                showNoRestoreAlert = false
            } label: {
                Text("OK")
            }
        } message: {
            Text("We didn't find any subscription to restore")
        }
        .alert("Subscription Active", isPresented: $showActiveSubscriptionAlert) {
            Button {
                showActiveSubscriptionAlert = false
            } label: {
                Text("OK")
            }
        } message: {
            Text("You already have an active subscription. Enjoy the premium features!")
        }
        .overlay {
            if purchaseService.processing ||
                purchaseService.processingRestore {
                ZStack {
                    Color.black.opacity(0.3)
                    ProgressView()
                        .controlSize(.large)
                        .progressViewStyle(.circular)
                }
            }
        }
    }
    
    private func privacyPolicyButtonPressed() {
        guard let url = appState.privacyPolicy else { return }
        openUrl(url)
    }
    
    private func termsOfUseButtonPressed() {
        guard let url = appState.termsOfUse else { return }
        openUrl(url)
    }
    
    private func feedbackButtonPressed() {
        EfficinacyCaller.shared.callHaptic()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            guard let url = appState.contactUs else { return }
            openUrl(url)
        }
    }
    
    private func shareButtonPressed() {
        guard let url = appState.appLink else { return }
        
        let AV = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        
        windowScene?.keyWindow?.rootViewController?.present(AV, animated: true, completion: nil)
    }
    
    private func restoreButtonPresses() {
        Task {
            await purchaseService.restorePurchases()
            if !purchaseService.hasPremium {
                showNoRestoreAlert = true
            } else {
                showActiveSubscriptionAlert = true
            }
        }
    }
}

struct ToggleRow: View {
    let title: String
    @State var isEnabled = false
    
    @AppStorage("local") var isFaceIDEnabled: Bool = false
    
    var body: some View {
        HStack {
            Text(title)
                .font(.semiBold(size: 16))
                .foregroundStyle(.c090A36)
            Spacer()
            Toggle("", isOn: $isFaceIDEnabled)
                .labelsHidden()
                .tint(.c2B78FF)
                .onChange(of: isFaceIDEnabled) { oldValue, newValue in
                    isFaceIDEnabled = newValue
                    isEnabled = newValue
                    
                    if newValue == true {
                        authenticate()
                    }
                }
        }
        .padding()
        .background(.cF3F7FF)
        .frame(height: 62)
        .cornerRadius(31)
    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Grant access to Face ID to enable biometrics to protect application"
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
            }
        }
    }
}

struct SettingsButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
            EfficinacyCaller.shared.callHaptic()
        }) {
            HStack {
                Image(icon)
                    .padding()
                    .frame(width: 48, height: 48)
                
                Text(title)
                    .font(.semiBold(size: 16))
                    .foregroundColor(.c090A36)
                Spacer()
            }
            .padding(.leading, 6)
            .padding(.top, 6)
            .padding(.bottom, 6)
            .background(.cF3F7FF)
            .frame(height: 60)
            .cornerRadius(30)
        }
    }
}
