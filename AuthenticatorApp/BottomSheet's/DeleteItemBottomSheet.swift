//
//  DeleteItemBottomSheet.swift
//  AuthenticatorApp
//
//  Created by Gideon Thackery on 20/03/2025.
//

import SwiftUI

struct DeleteItemBottomSheet: View {
    @Binding var isPresented: Bool
    var action: () -> Void  // No Binding here, just a closure
    
    var body: some View {
        VStack {
            // Title
            Text("Do you really want to \ndelete your account?")
                .font(.bold(size: 26))
                .multilineTextAlignment(.center)
                .foregroundColor(.c090A36)
                .padding(.top, 10)
                .padding(.bottom, 8)
            
            // Delete Button
            Button(action: {
                EfficinacyCaller.shared.callHaptic()
                action()  // Trigger the passed action closure
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    isPresented = false
                }
            }) {
                Text("Delete")
                    .font(.bold(size: 18))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 22.5)
                    .foregroundColor(.white)
            }
            .background(LinearGradient(colors: [.c4E8EFF, .c3069FE], startPoint: .top, endPoint: .bottom))
            .frame(height: 68)
            .clipShape(RoundedRectangle(cornerRadius: 34))
            
            // Cancel Button
            Button(action: {
                EfficinacyCaller.shared.callHaptic()
                isPresented = false
            }) {
                Text("Cancel")
                    .font(.bold(size: 18))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 22.5)
                    .foregroundColor(.c090A36)
            }
            .background(.cF3F7FF)
            .frame(height: 68)
            .clipShape(RoundedRectangle(cornerRadius: 34))
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .padding(.top, 20)
        .background(Color.white)
    }
}
