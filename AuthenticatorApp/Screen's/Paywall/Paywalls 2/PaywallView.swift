//
//  PaywallView.swift
//  AutoClickerAndTapper
//
//  Created by Philip Gachwentner on 18/09/2024.
//

import SwiftUI
import Adapty

struct PaywallView: View {
    
    @ObservedObject var viewModel: AccessScreenViewModel
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var purchaseService: PurchaseService
    @EnvironmentObject var globalPWState: GlobalPWState
    @State var showFailedAlert = false
    @State var showNoRestoreAlert = false
    @State var completed: Bool
    let product: AdaptyPaywallProduct
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(.paywall1)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                contentSection
            }
            if completed {
                closeButton
                    .padding(.horizontal, 16)
                    .padding(.top, 50)
            }
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
        .alert("Error", isPresented: $showNoRestoreAlert) {
            Button {
                showNoRestoreAlert = false
            } label: {
                Text("OK")
            }
        } message: {
            Text("We didn't find any subscription to restore")
        }
        .alert("Oops...", isPresented: $showFailedAlert) {
            Button {
                showFailedAlert = false
            } label: {
                Text("Cancel")
            }
            Button(role: .cancel, action: subscribe) {
                Text("Try again")
            }
        } message: {
            Text("Something went wrong.\nPlease try again")
        }
        .onAppear {
            if !completed {
                //some time to load the necessary data
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    completed = true
                }
            }
        }
    }

    private var closeButton: some View {
        let isFullVersion = purchaseService.isFV
        let foregroundColor = !isFullVersion ? Color._ECEFF1 : Color._ECEFF1.opacity(0.5)
        let backgroundColor = !isFullVersion ? Color._2E3340.opacity(0.8) : Color._2E3340.opacity(0.4)
        return  Button(action: {
            globalPWState.closeOnbPaywall.send(())
        }) {
            Image(systemName: "xmark")
                .resizable()
                .frame(width: 9, height: 9)
                .foregroundColor(foregroundColor)
                .padding(9)
                .background(backgroundColor)
                .clipShape(Circle())
        }
    }
    
    private var contentSection: some View {
        VStack {
            titleText
            
            if purchaseService.isFV {
                descriptionText
                pageIndicator
            } else {
                trialOptionView
            }

            subscribeButton
            termsButtonsView
        }
        .padding(.horizontal, 16)
        .padding(.top, 32)
        .padding(.bottom, 24)
        .background(
            VisualEffectBlur(blurStyle: .systemMaterial)
                .clipShape(CustomRoundedCornersShape(cornerRadius: 30, corners:  [.topLeft, .topRight]))
        )
        
    }
    
    
    private var titleText: some View {
        Text("Get unlimited access to autoclicker")
            .font(Font.regular(size: 32))
            .bold()
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.bottom, 8)
    }
    
    private var descriptionText: some View {
        Text("Click and scroll like an expert with a 3-day free trial, then \(purchaseService.calculateWeeklyPrice(from: purchaseService.appPaywall?.weeklyProduct.localizedPrice ?? "", weeks: 1, isPer: true))")
            .font(Font.regular(size: 15))
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
    }
    
    private var trialOptionView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("3-Day Trial, then \(purchaseService.calculateWeeklyPrice(from: purchaseService.appPaywall?.weeklyProduct.localizedPrice ?? "", weeks: 1))")
                    .font(Font.bold(size: 16))
                    .gradientForeground(colors: [Color._79ECE6, Color._79C2EC])
                
                Text("Auto renewable. Cancel anytime")
                    .font(Font.regular(size: 13))
                    .foregroundColor(Color._ECEFF1_60)
            }
            Spacer()
            
            Circle()
                .fill(LinearGradient(gradient: Gradient(colors: [Color._79ECE6, Color._79C2EC]), startPoint: .leading, endPoint: .trailing))
                .frame(width: 13, height: 13)
                .overlay(
                    Circle()
                        .stroke(LinearGradient(gradient: Gradient(colors: [Color._79ECE6, Color._79C2EC]), startPoint: .leading, endPoint: .trailing), lineWidth: 1)
                        .frame(width: 20, height: 20)
                )
        }
        .padding(.horizontal, 25)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 100)
                .stroke(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.cyan]), startPoint: .leading, endPoint: .trailing), lineWidth: 1)
        )
    }
    
    private var subscribeButton: some View {
        let text = purchaseService.isFV ? "Continue" : purchaseTitle
        return Button(action: subscribe) {
            GradientButtonView(text: text, isActive: true, isFrameInfinity: true)
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
            
            Button {
//                Haptic.impact(.light).generate()
                Task {
                    await purchaseService.restorePurchases()
                }
            } label: {
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
    
    private var pageIndicator: some View {
        let selectedColor = Color.white
        let unselectedColor = Color.gray.opacity(0.5)
        let selectedWidth: CGFloat = 32
        let unselectedWidth: CGFloat = 32
        let height: CGFloat = 4
        let isFullVersion = purchaseService.isFV

        // Вычисляем количество страниц, добавляем 2, если полная версия
        let totalPages = viewModel.onboardingScreens.count + (isFullVersion ? 2 : 0)
        // Текущий индекс с учетом полной версии
        let adjustedIndex = viewModel.currentIndex + (isFullVersion ? 1 : 0)

        return HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(adjustedIndex == index ? selectedColor : unselectedColor)
                    .frame(width: adjustedIndex == index ? selectedWidth : unselectedWidth, height: height)
            }
        }
        .padding(.vertical, 16)
    }
}

// MARK: - subscribe
extension PaywallView {
    
    var purchaseTitle: String {
        if let title = purchaseService.appPaywall?.config.fullPriceTitle {
            title
        } else {
            "Start 3-Day Trial, then \(purchaseService.calculateWeeklyPrice(from: purchaseService.appPaywall?.weeklyProduct.localizedPrice ?? "", weeks: 1))"
        }
    }
    
    func subscribe() {
//        Haptic.impact(.light).generate()
        Task {
           await purchaseService.makePurchase(product: product)
            if purchaseService.hasPremium {
                viewModel.state = .mainApp
            } else {
                showFailedAlert = true
            }
        }

    }

}
