//
//  InAppPaywallView.swift
//  AutoClickerAndTapper
//
//  Created by Gideon Thackery on 21/03/2025.
//

import SwiftUI
import Adapty
import Combine

struct InAppPaywallView: View {
    
    @StateObject var viewModel = AccessScreenViewModel()
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var purchaseService: PurchaseService
    @Environment(\.dismiss) var dismiss
    
    let paywall: PaywallModel
    
    @Environment(\.openURL) var openUrl
    @ObservedObject var appState: AppStateManager
    
    @State private var showFailedAlert = false
    @State private var showNoRestoreAlert = false
    @State var completed: Bool
    
    @State var animate = false
    @State var timer: AnyCancellable?
    
    var body: some View {
        NavigationStack {
            VStack {
                headerSection()
                Spacer()
                contentSection
            }
            .safeAreaPadding(.top, 50)
            .safeAreaPadding(.bottom, 28)
            .background(
                Image(.hbsfjgksdjfds)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
            )
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
            .alert("Oops...", isPresented: $showFailedAlert) {
                Button("Cancel") { }
                Button(role: .cancel) {
                    makePurchase()
                } label: {
                    Text("Try again")
                }
            } message: {
                Text("Something went wrong. \nPlease try again")
            }
            .onAppear {
                if !completed {
                    //some time to load the necessary data
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                        completed = true
                    }
                }
            }
            .edgesIgnoringSafeArea(.vertical)
        }
    }
    
    // MARK: - Header Section
    private func headerSection() -> some View {
        HStack {
            Spacer()
            if completed {
                Button {
                    EfficinacyCaller.shared.callHaptic()
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(purchaseService.isFV ? .afaskjdaskd : .sjhfgajkfasf)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 15)
    }
    
    private var contentSection: some View {
        VStack {
            Text("Access all features without limitations")
                .font(.bold(size: 32))
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, -6)
                .frame(maxWidth: .infinity, alignment: .leading)
            subscriptionOptions1()
            subscribeButton()
            termsAndRestoreSection()
        }
        .background(.white)
    }
    
    // MARK: - Subscription Options
    private func subscriptionOptions1() -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                SubscriptionButton(title: "1 MONTH", subtitle: "\(purchaseService.appPaywall?.monthlyProduct.localizedPrice ?? "")/month", isSelected: viewModel.selectedPlan == .monthly) {
                    viewModel.selectPlan(.monthly)
                }
                SubscriptionButton(title: "1 YEAR", subtitle: "\(purchaseService.appPaywall?.yearlyProduct.localizedPrice ?? "")/year", isSelected: viewModel.selectedPlan == .yearly) {
                    viewModel.selectPlan(.yearly)
                }
            }
            
            SubscriptionButton(title: "3-DAY TRIAL", subtitle: "then \(purchaseService.calculateWeeklyPrice(from: purchaseService.appPaywall?.weeklyProduct.localizedPrice ?? "", weeks: 1))", isSelected: viewModel.selectedPlan == .weekly) {
                viewModel.selectPlan(.weekly)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
    }
    
    private func subscribeButton() -> some View {
        Button {
            makePurchase()
        } label: {
            VStack {
                Text(purchaseService.isFV ? "Continue" : purchaseTitle)
                    .font(.bold(size: 18))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                
                if !purchaseService.isFV {
                    if viewModel.selectedPlan == .weekly || viewModel.selectedPlan == .monthly || viewModel.selectedPlan == .yearly {
                        Text("Auto renewable. Cancel anytime")
                            .foregroundStyle(.white.opacity(0.65))
                            .font(.medium(size: 12))
                    }
                }
            }
            .frame(height: 68)
            .background(
                LinearGradient(colors: [.c4E8EFF, .c3069FE], startPoint: .top, endPoint: .bottom)
                    .clipShape(.rect(cornerRadius: 32))
            )
        }
        .padding(.horizontal, 20)
        .scaleEffect(animate ? 0.95 : 1)
        .animation(.linear(duration: 1.0), value: animate)
        .onAppear {
            animate.toggle()
            timer = Timer.publish(every: 1.0, on: .main, in: .common)
                .autoconnect()
                .sink { _ in
                    animate.toggle()
                }
        }
    }
    
    // MARK: - Terms & Restore Section
    private func termsAndRestoreSection() -> some View {
        HStack {
            Text("By continuing, you agree to:")
                .font(.semiBold(size: 12))
                .foregroundColor(purchaseService.isFV ? .cA0A7D2 : .c090A36)
                .padding(.trailing, 20)
            
            termsButton(title: "Terms", url: appState.termsOfUse)
            termsButton(title: "Privacy", url: appState.privacyPolicy)
            restoreButton()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }
    
    private func termsButton(title: String, url: URL?) -> some View {
        Button {
            guard let url = url else { return }
            openUrl(url)
        } label: {
            Text(title)
                .font(.semiBold(size: 12))
                .foregroundColor(purchaseService.isFV ? .cA0A7D2 : .c090A36)
        }
        .padding(.trailing, 10)
    }
    
    private func restoreButton() -> some View {
        Button {
            EfficinacyCaller.shared.callHaptic()
            Task {
                await purchaseService.restorePurchases()
            }
        } label: {
            Text("Restore")
                .font(.semiBold(size: 12))
                .foregroundColor(purchaseService.isFV ? .cA0A7D2 : .c090A36)
        }
    }
}

// MARK: - Subscriptions
extension InAppPaywallView {
    var selectedPlan: AdaptyPaywallProduct {
        switch viewModel.selectedPlan {
        case .weekly:
            paywall.weeklyProduct
        case .monthly:
            paywall.monthlyProduct
        case .yearly:
            paywall.yearlyProduct
        }
    }
    
    func makePurchase() {
        EfficinacyCaller.shared.callHaptic()
        Task {
            await purchaseService.makePurchase(product: selectedPlan)
            if purchaseService.hasPremium {
                dismiss()
            } else {
                showFailedAlert = true
            }
        }
    }
    
    var purchaseTitle: String {
        switch viewModel.selectedPlan {
        case .weekly:
            "Try 3-Day Trial, then \(purchaseService.calculateWeeklyPrice(from: purchaseService.appPaywall?.weeklyProduct.localizedPrice ?? "", weeks: 1))"
        case .monthly:
            "Subscribe for \(purchaseService.appPaywall?.monthlyProduct.localizedPrice ?? "")/month"
        case .yearly:
            "Subscribe for \(purchaseService.appPaywall?.yearlyProduct.localizedPrice ?? "")/year"
        }
    }
}

// MARK: - Subscription Button
struct SubscriptionButton: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Text(title)
                    .font(.bold(size: 16))
                    .foregroundColor(isSelected ? .c2B78FF : .c090A36)
                
                Text(subtitle)
                    .font(.medium(size: 14))
                    .foregroundColor(.c090A36)
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(Color.cF3F7FF)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.c2B78FF, lineWidth: isSelected ? 3 : 0)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
