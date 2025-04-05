//
//  2FARootView.swift
//  AuthenticatorApp
//
//  Created by Gideon Thackery on 21/03/2025.
//

import SwiftUI
import StoreKit

struct RootView: View {
    @StateObject var quickActionService = QuickActionsService.instance
    @Environment(\.openURL) var openUrl
    
    var body: some View {
        AccessScreenView()
            .preferredColorScheme(.light)
            .onAppear {
                handleQuickAction()
            }
            .onChange(of: quickActionService.quickAction) { oldValue, newValue in
                handleQuickAction()
            }
    }
    
    private func handleQuickAction() {
        guard let action = quickActionService.quickAction else { return }
        defer { quickActionService.clearQuickAction() }
        
        switch action {
        case .rating:
            requestAppReview()
        case .question, .help:
            sendEmail(to: "gideonthackery12@outlook.com")
        }
    }
    
    private func requestAppReview() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            AppStore.requestReview(in: windowScene)
        }
    }
    
    private func sendEmail(to email: String) {
        if let url = URL(string: "mailto:\(email)"), UIApplication.shared.canOpenURL(url) {
            openUrl(url)
        }
    }
}
