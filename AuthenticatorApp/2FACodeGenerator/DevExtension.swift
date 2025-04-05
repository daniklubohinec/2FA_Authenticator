//
//  URL+queryItemsExtension.swift
//  Authenticator
//
//  Created by Gideon Thackery on 21/03/2025.
//

import Foundation
import SwiftKeychainWrapper
import SwiftUI
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
        URL(string: "mailto:gideonthackery12@outlook.com")
    }
    var appLink: URL? {
        URL(string: "https://apps.apple.com/app/6742843015")
    }
}

struct TimerRowProgressView: View {
    @Binding var progress: Float
    @Binding var color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 4)
                .opacity(0.3)
                .foregroundColor(.white)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(max(0.01, progress), 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                .foregroundColor(color)
                .rotationEffect(Angle(degrees: 270))
                .animation(.linear, value: progress)
        }
    }
}

extension KeychainWrapper.Key {
    static let accounts: KeychainWrapper.Key = "FAAuthenticator"
}

extension KeychainWrapper {
    //    static let serviceName = "accounts"
    //    static let accessGroup = "group.dev.basjansen.Authenticator"
    
    static let serviceName = "FAAuthenticator"
    static let accessGroup = "group.com.authenticator.thackery"
}

extension URL {
    var queryItemsData: [String: String]? {
        guard let query = self.query else { return nil }
        
        var queryStrings = [String: String]()
        for pair in query.components(separatedBy: "&") {
            
            let key = pair.components(separatedBy: "=")[0]
            
            let value = pair
                .components(separatedBy:"=")[1]
                .replacingOccurrences(of: "+", with: " ")
                .removingPercentEncoding ?? ""
            
            queryStrings[key] = value
        }
        return queryStrings
    }
}
