//
//  InAppPaywallView.swift
//  AutoClickerAndTapper
//
//  Created by Philip Gachwentner on 11/10/2024.
//

import SwiftUI
import Adapty

struct InAppPaywallView: View {
    
    @StateObject var viewModel = AccessScreenViewModel()
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var purchaseService: PurchaseService
    
    let paywall: PaywallModel

    @State private var showFailedAlert = false
    @State private var showNoRestoreAlert = false
    @State var completed: Bool

    
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
        .alert("Oops...", isPresented: $showFailedAlert) {
            Button(role: .cancel, action: makePurchase) {
                Text("Try again")
            }
            Button {
                showFailedAlert = false
            } label: {
                Text("Cancel")
            }
        } message: {
            Text("Something went wrong. \nPlease try again")
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
//            Haptic.impact(.light).generate()
            presentationMode.wrappedValue.dismiss()
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
            subscriptionOptions
            autoRenewableText
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
        Text("Unlimited access to autoclicker")
            .font(Font.regular(size: 32))
            .bold()
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.bottom, 8)
    }
    
    private var subscriptionOptions: some View {
        let monthlyProduct = purchaseService.appPaywall?.monthlyProduct
        let weeklyProduct = purchaseService.appPaywall?.weeklyProduct
        let yearlyProduct = purchaseService.appPaywall?.yearlyProduct

        return HStack(spacing: 16) {
            subscriptionButton(title: "Monthly",
                               price: monthlyProduct?.localizedPrice ?? "",
                               weeklyRate: purchaseService.calculateWeeklyPrice(from: monthlyProduct?.localizedPrice ?? "", weeks: 4),
                               isSelected: viewModel.selectedPlan == .monthly,
                               tagText: "Popular")
                .onTapGesture {
//                    Haptic.impact(.light).generate()
                    viewModel.selectPlan(.monthly)
                }
            subscriptionButton(title: "Weekly",
                               price: "then \(weeklyProduct?.localizedPrice ?? "")",
                               weeklyRate: purchaseService.calculateWeeklyPrice(from: weeklyProduct?.localizedPrice ?? "", weeks: 1),
                               isSelected: viewModel.selectedPlan == .weekly,
                               tagText: "3-day Trial")
                .onTapGesture {
//                    Haptic.impact(.light).generate()
                    viewModel.selectPlan(.weekly)
                }
            subscriptionButton(title: "Yearly",
                               price: yearlyProduct?.localizedPrice ?? "",
                               weeklyRate: purchaseService.calculateWeeklyPrice(from: yearlyProduct?.localizedPrice ?? "", weeks: 52),
                               isSelected: viewModel.selectedPlan == .yearly,
                               tagText: "\(purchaseService.calculateDiscountPercentage(weeklyPrice: weeklyProduct?.localizedPrice, yearlyPrice: yearlyProduct?.localizedPrice))% OFF")
                .onTapGesture {
//                    Haptic.impact(.light).generate()
                    viewModel.selectPlan(.yearly)
                }
        }
        .padding(.bottom, 16)
    }

    private func subscriptionButton(title: String, price: String, weeklyRate: String, isSelected: Bool, tagText: String? = nil) -> some View {

        let selectedTextColor = Color._1D242F
        let unselectedTextColor = Color._ECEFF1
        let textColor: Color = isSelected ? selectedTextColor : unselectedTextColor
        let selectedBackgroudColor = Color._79C2EC
        let unselectedBackgroudColor = Color._2E3340
        let backgroundColor: Color = isSelected ? selectedBackgroudColor : unselectedBackgroudColor
        
        let selectedTagBackgroundColor: Color = isSelected ? Color._ECEFF1 : Color._79C2EC

        return VStack {
            if let tagText {
                Text(tagText)
                    .font(Font.regular(size: 11))
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color._050C16)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 6)
                    .background(selectedTagBackgroundColor)
                    .cornerRadius(44)
            }
            
            Text(title)
                .font(Font.regular(size: 16))
                .bold()
                .foregroundColor(textColor)
            
            Text(price)
                .font(Font.regular(size: 12))
                .foregroundColor(textColor)

            Rectangle()
                .frame(height: 1)
                .foregroundColor(isSelected ? Color._1D242F.opacity(0.1) : Color._ECEFF1.opacity(0.1))
                .padding(.horizontal, 20)
                .cornerRadius(9)
     
            
            Text(weeklyRate)
                .font(Font.regular(size: 12))
                .foregroundColor(textColor)
                .padding(.top, 2)
                .padding(.bottom, 15)
  
        }
        .frame(maxWidth: .infinity)
        .padding(6)
        .background(backgroundColor)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
    }
    
    private var subscribeButton: some View {
        Button(action: makePurchase) {
            GradientButtonView(text: purchaseTitle, isActive: true, isFrameInfinity: true)
        }
    }
        
    private var termsButtonsView: some View {
        HStack(spacing: 24) {
            Button(action: {
//                Haptic.impact(.light).generate()
                viewModel.openTermsOfService()
            }) {
                Text("Terms of Use")
                    .font(Font.regular(size: 12))
                    .foregroundColor(Color._ECEFF1_60)
                    .underline()
            }
            
            Button(action: {
//                Haptic.impact(.light).generate()
                Task {
                    await purchaseService.restorePurchases()
                    if purchaseService.hasPremium {
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        showNoRestoreAlert = true
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
    

    private var autoRenewableText: some View {
        Text("Auto renewable. Cancel anytime")
            .font(Font.regular(size: 14))
            .foregroundColor(Color.white)
    }
    
    func itemSummary(_ price: String?, withTrial: Bool) -> String {
        guard let price else { return "" }
        if withTrial {
           return  "then" + " " + price
        } else {
            return price
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
//        Haptic.impact(.light).generate()
        Task {
            await purchaseService.makePurchase(product: selectedPlan)
            if purchaseService.hasPremium {
                presentationMode.wrappedValue.dismiss()
            } else {
                showFailedAlert = true
            }
        }
    }
    
    var purchaseTitle: String {
        if let title = purchaseService.appPaywall?.config.fullPriceTitle {
            title
        } else {
            switch viewModel.selectedPlan {
            case .monthly:
                "Start Monthly Plan for \(purchaseService.appPaywall?.monthlyProduct.localizedPrice ?? "")"
            case .weekly:
                "Start 3-Day Trial, then \(purchaseService.calculateWeeklyPrice(from: purchaseService.appPaywall?.weeklyProduct.localizedPrice ?? "", weeks: 1))"
            case .yearly:
                "Start Yearly Plan for \(purchaseService.appPaywall?.yearlyProduct.localizedPrice ?? "")"
            }
        }
    }
}
