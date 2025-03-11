//
//  AccessScreenView.swift
//  AutoClickerAndTapper
//
//  Created by Philip Gachwentner on 16/09/2024.
//

import SwiftUI

struct AccessScreenView: View {
    
    @StateObject private var viewModel = AccessScreenViewModel()
    
    @Environment(\.scenePhase) var phase
    @EnvironmentObject var purchaseService: PurchaseService
    @EnvironmentObject var globalPWState: GlobalPWState
    
    @AppStorage(AppStorageKeys.hasSeenOnboarding) private var hasSeenOnboarding: Bool = false
    
    @State private var paywall: PaywallModel?

    var body: some View {
        VStack {
            switch viewModel.state {
            case .launch:
                Image(.splashScreen)
                    .resizable()
                    .ignoresSafeArea()
                    .task {
                        await purchaseService.checkPurchases()
                        if purchaseService.hasPremium {
                            viewModel.state = .mainApp
                        } else {
                            await purchaseService.getPaywalls()
                            if hasSeenOnboarding {
                                viewModel.state = .mainApp
                            } else {
                                viewModel.state = .onboarding
                            }
                        }
                    }
            case .onboarding:
                OnboardingView(viewModel: viewModel)
                    .background(Color.black)
            case .paywall:
                if let product = purchaseService.appPaywall?.weeklyProduct {
                    PaywallView(viewModel: viewModel, completed: !purchaseService.isFV, product: product)
                } else {
                    //will never be called
                    EmptyView()
                }
            case .mainApp:
                TabsView()
                    .onAppear {
                        hasSeenOnboarding = true
                    }
            }
        }
        .ignoresSafeArea()
        
        .onReceive(globalPWState.closeOnbPaywall) { _ in
            viewModel.state = .mainApp
        }
        .onReceive(globalPWState.paywallData) { pw in
            updatePaywall(pw)
            print("Received paywall: \(pw)")
        }
        .fullScreenCover(item: $paywall) { pw in
            InAppPaywallView(paywall: pw, completed: !purchaseService.isFV)
        }
        .alert("Error", isPresented: $globalPWState.paywallsNotLoadedAlert) {
            Button(role: .cancel) {
                globalPWState.paywallsNotLoadedAlert = false
            } label: {
                Text("OK")
            }
        } message: {
            Text("It looks like you don't have an active subscription and you're not connected to the internet. \nPlease connect to the internet and try again.")
        }

        .onChange(of: phase) {
            switch phase {
            case .active:
                guard viewModel.state == .mainApp else { return }
                if let pw = purchaseService.appPaywall,
                    !purchaseService.hasPremium {
                    updatePaywall(pw)
                }
            default:
                break
            }
        }
    }
    
    @MainActor
    func updatePaywall(_ pw: PaywallModel) {
        paywall = pw
    }
}


struct CompletedView: View {
    var body: some View {
        VStack {
            Spacer()
        }
    }
}


extension View {
    func gradientForeground(colors: [Color]) -> some View {
        self.overlay(
            LinearGradient(gradient: Gradient(colors: colors), startPoint: .leading, endPoint: .trailing)
        )
        .mask(self)
    }
}
