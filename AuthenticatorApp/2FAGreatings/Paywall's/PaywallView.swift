//
//  PaywallView.swift
//  AutoClickerAndTapper
//
//  Created by Gideon Thackery on 21/03/2025.
//

import SwiftUI
import Adapty
import Combine

struct PaywallView: View {
    
    @ObservedObject var viewModel: AccessScreenViewModel
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var purchaseService: PurchaseService
    @EnvironmentObject var globalPWState: GlobalPWState
    @State var showFailedAlert = false
    @State var showNoRestoreAlert = false
    @State var completed: Bool
    let product: AdaptyPaywallProduct
    
    @State var animate = false
    @State var timer: AnyCancellable?
    
    @ObservedObject var appState: AppStateManager
    @Environment(\.openURL) var openUrl
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                if completed {
                    Button {
                        EfficinacyCaller.shared.callHaptic()
                        globalPWState.closeOnbPaywall.send(())
                    } label: {
                        Image(purchaseService.isFV ? .afaskjdaskd : .sjhfgajkfasf)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 15)
            Spacer()
            contentSection
        }
        .background(
            Image(.eqpowfqwfq)
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
        .alert("Error", isPresented: $showNoRestoreAlert) {
            Button {
                showNoRestoreAlert = false
            } label: {
                Text("OK")
            }
        } message: {
            Text("We didn't find any subscription to restore")
        }
//        .alert("Oops...", isPresented: $showFailedAlert) {
//            Button {
//                showFailedAlert = false
//            } label: {
//                Text("Cancel")
//            }
//            Button(role: .cancel, action: subscribe) {
//                Text("Try again")
//            }
//        } message: {
//            Text("Something went wrong.\nPlease try again")
//        }
        .onAppear {
            if !completed {
                //some time to load the necessary data
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    completed = true
                }
            }
        }
    }
    
    private var titleText: some View {
        Text("Access all features without limitations")
            .font(.bold(size: 32))
            .foregroundColor(.c090A36)
            .multilineTextAlignment(.leading)
    }
    
    private var descriptionText: some View {
        Text("Safeguard your accounts with\n a 3-day trial, ")
            .font(.medium(size: 14))
            .foregroundColor(purchaseService.isFV ? .cA0A7D2 : .c090A36) +
        Text("then \(purchaseService.calculateWeeklyPrice(from: purchaseService.appPaywall?.weeklyProduct.localizedPrice ?? "", weeks: 1, isPer: true))")
            .font(purchaseService.isFV ? .medium(size: 14) : .bold(size: 14))
            .foregroundStyle(purchaseService.isFV ? .cA0A7D2 : .c2B78FF)
    }
    
    private var closeButton: some View {
        let isFullVersion = purchaseService.isFV
        let foregroundColor = !isFullVersion ? Color.black : Color.black.opacity(0.5)
        let backgroundColor = !isFullVersion ? Color.white.opacity(0.8) : Color.white.opacity(0.4)
        return  Button(action: {
            EfficinacyCaller.shared.callHaptic()
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
            if purchaseService.isFV {
                HStack {
                    pageIndicator
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            titleText
                .padding(.horizontal, 20)
                .padding(.top, 15)
                .padding(.bottom, -10)
                .frame(maxWidth: .infinity, alignment: .leading)
            descriptionText
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
            subscribeButton
            termsAndRestoreSection()
        }
        .background(.white)
    }
    
    private var subscribeButton: some View {
        Button {
            subscribe()
        } label: {
            VStack {
                Text(purchaseService.isFV ? "Continue" : "Start 3-Day Trial, then \(purchaseService.calculateWeeklyPrice(from: purchaseService.appPaywall?.weeklyProduct.localizedPrice ?? "", weeks: 1))")
                    .font(.bold(size: 18))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                if !purchaseService.isFV {
                    Text("Auto renewable. Cancel anytime")
                        .foregroundStyle(.white.opacity(0.65))
                        .font(.medium(size: 12))
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
            EfficinacyCaller.shared.callHaptic()
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
    
    private var pageIndicator: some View {
        let selectedColor = Color.c2B78FF
        let unselectedColor = Color.c2B78FF.opacity(0.2)
        let selectedWidth: CGFloat = 41
        let unselectedWidth: CGFloat = 20
        let height: CGFloat = 6
        let isFullVersion = purchaseService.isFV
        
        // Вычисляем количество страниц, добавляем 2, если полная версия
        let totalPages = viewModel.onboardingScreens.count + (isFullVersion ? 2 : 1)
        // Текущий индекс с учетом полной версии
        let adjustedIndex = viewModel.currentIndex + (isFullVersion ? 1 : 1)
        
        return HStack(spacing: 4) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(adjustedIndex == index ? selectedColor : unselectedColor)
                    .frame(width: adjustedIndex == index ? selectedWidth : unselectedWidth, height: height)
            }
        }
    }
}

// MARK: - subscribe
extension PaywallView {
    func subscribe() {
        EfficinacyCaller.shared.callHaptic()
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
