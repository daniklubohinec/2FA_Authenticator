//
//  OnboardingView.swift
//  AutoClickerAndTapper
//
//  Created by Gideon Thackery on 21/03/2025.
//

import SwiftUI
import Combine

struct OnboardingView: View {
    
    @ObservedObject var viewModel: AccessScreenViewModel
    @EnvironmentObject var purchaseService: PurchaseService
    
    @State var animate = false
    @State var timer: AnyCancellable?
    
    var body: some View {
        VStack {
            Spacer()
            contentSection
        }
        .background(
            viewModel.currentScreen.image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
        )
        .onChange(of: viewModel.currentIndex) {
            if purchaseService.isFV,
               viewModel.currentIndex == 1 {
                viewModel.requestAppReview()
            }
        }
        .safeAreaPadding(.top, 50)
        .safeAreaPadding(.bottom, 28)
    }
    
    private var contentSection: some View {
        VStack {
            if purchaseService.isFV {
                HStack {
                    pageIndicator
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            titleText
                .padding(.horizontal, 20)
                .padding(.top, 15)
                .frame(maxWidth: .infinity, alignment: .leading)
            descriptionText
                .padding(.horizontal, 20)
                .padding(.top, 1)
                .padding(.bottom, 15)
                .frame(maxWidth: .infinity, alignment: .leading)
            continueButton
        }
        .background(.white)
    }
    
    
    private var titleText: some View {
        Text(viewModel.currentScreen.title)
            .font(.bold(size: 32))
            .foregroundColor(.c090A36)
            .multilineTextAlignment(.leading)
    }
    
    private var descriptionText: some View {
        Text(viewModel.currentScreen.description)
            .font(.medium(size: 14))
            .foregroundColor(purchaseService.isFV ? .cA0A7D2 : .c090A36)
    }
    
    private var pageIndicator: some View {
        let selectedColor = Color.c2B78FF
        let unselectedColor = Color.c2B78FF.opacity(0.2)
        let selectedWidth: CGFloat = 41
        let unselectedWidth: CGFloat = 20
        let height: CGFloat = 6
        let isFullVersion = purchaseService.isFV
        let totalPages = viewModel.onboardingScreens.count + (isFullVersion ? 2 : 1)
        let adjustedIndex = viewModel.currentIndex
        
        return HStack(spacing: 4) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(adjustedIndex == index ? selectedColor : unselectedColor)
                    .frame(width: adjustedIndex == index ? selectedWidth : unselectedWidth, height: height)
            }
        }
    }
    
    private var continueButton: some View {
        Button {
            nextScreen()
        } label: {
            VStack {
                Text("Continue")
                    .font(.bold(size: 18))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
            }
            .frame(height: 68)
            .background(
                LinearGradient(colors: [.c4E8EFF, .c3069FE], startPoint: .top, endPoint: .bottom)
                    .clipShape(.rect(cornerRadius: 32))
            )
        }
        .padding(.horizontal, 20)
        .padding(.bottom)
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
    
    func nextScreen() {
        EfficinacyCaller.shared.callHaptic()
        if viewModel.currentIndex < viewModel.onboardingScreens.count - 1 {
            viewModel.currentIndex += 1
        } else if purchaseService.appPaywall != nil {
            viewModel.state = .paywall
        } else {
            viewModel.state = .mainApp
        }
    }
}
