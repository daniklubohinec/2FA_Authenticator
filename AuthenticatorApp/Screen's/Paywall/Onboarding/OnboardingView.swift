//
//  OnboardingView.swift
//  AutoClickerAndTapper
//
//  Created by Philip Gachwentner on 18/09/2024.
//

import SwiftUI

struct OnboardingView: View {
    
    @ObservedObject var viewModel: AccessScreenViewModel
    @EnvironmentObject var purchaseService: PurchaseService
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            viewModel.currentScreen.image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                contentSection
            }
        }
        .onChange(of: viewModel.currentIndex) {
            if purchaseService.isFV,
               viewModel.currentIndex == 2 {
                viewModel.requestAppReview()
            }
        }
    }
    
    private var contentSection: some View {
        VStack {
            titleText
            descriptionText
            pageIndicator
            continueButton
            termsButtonsView
                    .opacity(0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 32)
        .padding(.bottom, 24)
        .background(
            ZStack {
                VisualEffectBlur(blurStyle: .systemMaterial)
                    .clipShape(CustomRoundedCornersShape(cornerRadius: 30, corners:  [.topLeft, .topRight]))
            }
        )
        
    }
    
    
    private var titleText: some View {
        Text(viewModel.currentScreen.title)
            .font(Font.regular(size: 32))
            .bold()
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.bottom, 8)
        
    }
    
    private var descriptionText: some View {
        Text(viewModel.currentScreen.description)
            .font(Font.regular(size: 15))
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
    }
    
    private var pageIndicator: some View {
        let selectedColor = Color.white
        let unselectedColor = Color.gray.opacity(0.5)
        let selectedWidth: CGFloat = 32
        let unselectedWidth: CGFloat = 32
        let height: CGFloat = 4
        let isFullVersion = purchaseService.isFV
        let totalPages = viewModel.onboardingScreens.count + (isFullVersion ? 2 : 0)
        let adjustedIndex = viewModel.currentIndex

        return HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(adjustedIndex == index ? selectedColor : unselectedColor)
                    .frame(width: adjustedIndex == index ? selectedWidth : unselectedWidth, height: height)
            }
        }
        .padding(.vertical, 16)
    }
    
    private var continueButton: some View {
        Button(action: nextScreen) {
            GradientButtonView(text: "Continue", isActive: true, isFrameInfinity: true)
        }
    }
    
    func nextScreen() {
//        Haptic.impact(.light).generate()
        if viewModel.currentIndex < viewModel.onboardingScreens.count - 1 {
            viewModel.currentIndex += 1
        } else if purchaseService.appPaywall != nil {
            viewModel.state = .paywall
        } else {
            viewModel.state = .mainApp
        }
    }
    
    private var termsButtonsView: some View {
        HStack(spacing: 24) {
            Button(action: {
//                Haptic.impact(.light).generate()
                viewModel.openTermsOfService()
            }) {
                Text("Terms of Use")
                    .font(Font.regular(size: 13))
                    .foregroundColor(Color._ECEFF1_60)
                    .underline()
            }
            
            Button(action: {
                Task {
//                    Haptic.impact(.light).generate()
                    await purchaseService.restorePurchases()
                    if purchaseService.hasPremium {
                        viewModel.state = .mainApp
                    }
                }
            }) {
                Text("Restore")
                    .font(Font.regular(size: 13))
                    .foregroundColor(Color._ECEFF1_60)
                    .underline()
            }
            
            Button(action: {
//                Haptic.impact(.light).generate()
                viewModel.openPrivacyPolicy()
            }) {
                Text("Privacy Policy")
                    .font(Font.regular(size: 13))
                    .foregroundColor(Color._ECEFF1_60)
                    .underline()
            }
        }
        .padding()
    }
}
