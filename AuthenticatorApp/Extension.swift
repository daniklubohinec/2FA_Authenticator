//
//  Extension.swift
//  AuthenticatorApp
//
//  Created by Danik Lubohinec on 27/02/2025.
//

import UIKit
import StoreKit

protocol ImpactCaller {
    func callHaptic()
}

final class EfficinacyCaller: ImpactCaller {
    static let shared = EfficinacyCaller()
    
    // MARK: Internal
    private init() { }
    
    func callHaptic() {
        impact.impactOccurred()
    }
    
    // MARK: Fileprivate
    fileprivate let impact = UIImpactFeedbackGenerator(style: .light)
}

class AppStateManager: ObservableObject {
    @MainActor func showRequestReview() {
        if let windowScene = UIApplication.shared.connectedScenes
            .first as? UIWindowScene {
            AppStore.requestReview(in: windowScene)
        }
    }
    
    var privacyPolicy: URL? {
        URL(string: "https://docs.google.com/document/d/1HRgcNqha-fC4chJ4DeLlCvWCJh_mO-3vVKGwuEQH-rA/edit?tab=t.0")
    }
    var termsOfUse: URL? {
        URL(string: "https://docs.google.com/document/d/1fTO5RAxvjp36lDE-nYtWHZbt2dmKQwtcipQVtpO5Yj8/edit?tab=t.0")
    }
    var contactUs: URL? {
        URL(string: "gideonthackery12@outlook.com")
    }
    var appLink: URL? {
        URL(string: "https://apps.apple.com/pl/app/")
    }
}
