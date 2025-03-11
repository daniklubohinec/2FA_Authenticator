//
//  PaywallScreen.swift
//  AuthenticatorApp
//
//  Created by Danik Lubohinec on 04/03/2025.
//

import SwiftUI
import Combine

struct PaywallScreen: View {
    
    @ObservedObject var appState: AppStateManager
    @Environment(\.openURL) var openUrl
    @Environment(\.dismiss) var dismiss
    @State private var selectedOption: SubscriptionOption? = .weekly
    
    @EnvironmentObject var purchaseService: PurchaseService
    @EnvironmentObject var globalPWState: GlobalPWState
    
    @State var animate = false
    @State var timer: AnyCancellable?
    
    enum SubscriptionOption {
        case weekly, monthly, yearly
    }
    
    var body: some View {
        VStack {
            headerSection()
            Spacer()
            subscriptionOptions()
            subscribeButton()
            termsAndRestoreSection()
        }
        .background(backgroundImage())
    }
    
    // MARK: - Header Section
    private func headerSection() -> some View {
        HStack {
            Text("Access all features without limitations")
                .font(.bold(size: 32))
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            Button {
                dismiss()
            } label: {
                Image(purchaseService.isFV ? .sjhfgajkfasf : .afaskjdaskd)
                    .padding(.bottom, 60)
                    .padding(.trailing, 20)
            }
        }
    }
    
    // MARK: - Subscription Options
    private func subscriptionOptions() -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                SubscriptionButton(title: "1 MONTH", subtitle: "$19.99/month", isSelected: selectedOption == .monthly) {
                    selectedOption = .monthly
                }
                SubscriptionButton(title: "1 YEAR", subtitle: "$49.99/year", isSelected: selectedOption == .yearly) {
                    selectedOption = .yearly
                }
            }
            
            SubscriptionButton(title: "3-DAY TRIAL", subtitle: "then $6.99/week", isSelected: selectedOption == .weekly) {
                selectedOption = .weekly
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
    }
    
    // MARK: - Subscribe Button
    private func subscribeButton() -> some View {
        Button {
            //                Task {
            //                    await purchaseService.makePurchase(product: paywall.product)
            //                    if purchaseService.hasPremium {
            //                        if stateCoordinator.state == .onbPw {
            //                            stateCoordinator.state = .flow
            //                        } else {
            //                            dismiss()
            //                        }
            //                    }
            //                }
            
        } label: {
            VStack {
                Text(purchaseService.isFV ? subscriptionButtonTitle() : "Continue")
                    .font(.bold(size: 18))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                
                if purchaseService.isFV {
                    if selectedOption == .weekly || selectedOption == .monthly || selectedOption == .yearly {
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
    
    private func subscriptionButtonTitle() -> String {
        switch selectedOption {
        case .weekly:
            return "Try 3-Day Trial, then $6.99/week"
        case .monthly:
            return "Subscribe for $19.99/month"
        case .yearly:
            return "Subscribe for $49.99/year"
        case nil:
            return "Continue"
        }
    }
    
    // MARK: - Terms & Restore Section
    private func termsAndRestoreSection() -> some View {
        HStack {
            Text("By continuing, you agree to:")
                .font(.semiBold(size: 12))
                .foregroundColor(purchaseService.isFV ? .c090A36 : .cA0A7D2)
                .padding(.trailing, 20)
            
            termsButton(title: "Terms", url: appState.termsOfUse)
            termsButton(title: "Privacy", url: appState.privacyPolicy)
            restoreButton()
        }
        .padding()
    }
    
    private func termsButton(title: String, url: URL?) -> some View {
        Button {
            guard let url = url else { return }
            openUrl(url)
        } label: {
            Text(title)
                .font(.semiBold(size: 12))
                .foregroundStyle(purchaseService.isFV ? .c090A36 : .cA0A7D2)
        }
        .padding(.trailing, 10)
    }
    
    private func restoreButton() -> some View {
        Button {
            /* Restore Purchases */
        } label: {
            Text("Restore")
                .font(.semiBold(size: 12))
                .foregroundStyle(purchaseService.isFV ? .c090A36 : .cA0A7D2)
        }
    }
    
    // MARK: - Background Image
    private func backgroundImage() -> some View {
        Image(.hbsfjgksdjfds)
            .resizable()
            .edgesIgnoringSafeArea(.all)
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
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
//
//#Preview {
//    PaywallScreen(appState: AppStateManager())
//}
