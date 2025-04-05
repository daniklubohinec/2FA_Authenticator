//
//  AccessScreenViewModel.swift
//  AutoClickerAndTapper
//
//  Created by Gideon Thackery on 21/03/2025.
//

import Foundation
import SwiftUI
import Adapty
import StoreKit

enum SubscriptionPlan: String {
    case weekly
    case monthly
    case yearly
    
    var id: Self { self }
    
    var count: Double {
        switch self {
        case .weekly:
            7
        case .monthly:
            30
        case .yearly:
            365
        }
    }
}

class AccessScreenViewModel: ObservableObject {
    @Environment(\.openURL) var openURL
    @Published var state: AccessFlowState = .launch
    //    @AppStorage(AppStorageKeys.hasSeenOnboarding) private var hasSeenOnboarding: Bool = false
    @Published var selectedPlan: SubscriptionPlan = .weekly
    
    let onboardingScreens: [OnboardingModel] = [
        OnboardingModel(title: "Boost the protection of your accounts",
                        description: "Ensure your accounts remain leak-free with \npersonalized access control",
                        image: Image(.jkasdaskljdasjd1)),
        OnboardingModel(title: "Instant access through your camera",
                        description: "Automatically scan a QR code for a seamless \naccount setup process",
                        image: Image(.jkasdaskljdasjd2)),
        OnboardingModel(title: "Secure all your online accounts",
                        description: "Protect all your social media, crypto and other \naccounts with 2-step verification",
                        image: Image(.jkasdaskljdasjd3))
    ]
    
    @Published var currentIndex: Int = 0
    
    var currentScreen: OnboardingModel {
        return onboardingScreens[currentIndex]
    }
    
    func closeScreen() {
        state = .mainApp
    }
    
    func selectPlan(_ plan: SubscriptionPlan) {
        selectedPlan = plan
    }
    
    func requestAppReview() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}
