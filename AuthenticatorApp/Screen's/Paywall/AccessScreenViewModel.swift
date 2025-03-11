//
//  AccessScreenViewModel.swift
//  AutoClickerAndTapper
//
//  Created by Philip Gachwentner on 16/09/2024.
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
        OnboardingModel(title: "Automate daily tasks with Auto Clicker",
                           description: "Use an autoclicker or scroller and get rid of a chore.",
                        image: Image(.onb1)),
        OnboardingModel(title: "Add your favorite sites for quick access",
                           description: "Save your favorite pages in a list so you can open them quickly and easily at any time.",
                           image: Image(.onb2)),
        OnboardingModel(title: "Configure your autoclicker settings",
                           description: "Customize the autoclicker to your tasks for maximum efficiency.",
                           image: Image(.onb3))
    ]
    
    @Published var currentIndex: Int = 0
    
    var currentScreen: OnboardingModel {
        return onboardingScreens[currentIndex]
    }
            
    func openPrivacyPolicy() {
        guard let url = URL(string: "https://docs.google.com/document/d/1P5S6rq02Aw5ru9ITnzYsgLoq_tUECpAhqzgrxx_iKdc/edit?usp=sharing") else { return }
        openURL(url)
    }
    
    func openTermsOfService() {
        guard let url = URL(string: "https://docs.google.com/document/d/1HoD1fzFNIbFGoE90k4Ft9A_5dgzpmt-0AOn7zueBx-o/edit?usp=sharing") else { return }
        openURL(url)
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
