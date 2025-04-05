//
//  CustomToastView.swift
//  AuthenticatorApp
//
//  Created by Gideon Thackery on 20/03/2025.
//

import SwiftUI

struct ToastView: View {
    var message: String
    var imageName: ImageResource
    
    var body: some View {
        VStack {
            Image(imageName)
            Text(message)
                .font(.bold(size: 20))
                .foregroundColor(.white)
                .padding(.top, -6)
        }
        .frame(width: 108, height: 105)
        .background(.cA0A7D2).cornerRadius(28)
    }
}

struct ToastModifier: ViewModifier {
    @Binding var isShowing: Bool
    var message: String
    var imageName: ImageResource
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if isShowing {
                ToastView(message: message, imageName: imageName)
                    .transition(.opacity)
                    .zIndex(1)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation {
                                isShowing = false
                            }
                        }
                    }
            }
        }
        .animation(.easeInOut, value: isShowing)
    }
}

extension View {
    func showToast(isShowing: Binding<Bool>, message: String, imageName: ImageResource) -> some View {
        self.modifier(ToastModifier(isShowing: isShowing, message: message, imageName: imageName))
    }
}
