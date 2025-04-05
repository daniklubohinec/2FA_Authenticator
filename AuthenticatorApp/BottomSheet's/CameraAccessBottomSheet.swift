//
//  CameraAccessBottomSheet.swift
//  AuthenticatorApp
//
//  Created by Gideon Thackery on 12/03/2025.
//

import SwiftUI

struct CameraAccessBottomSheet: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            // Title
            Text("Grant permission for \nCamera access")
                .font(.bold(size: 26))
                .multilineTextAlignment(.center)
                .foregroundColor(.c090A36)
                .padding(.top, 10)
                .padding(.bottom, 8)
            
            // Subtitle
            Text("This app’s access is currently turned off. \nGo to Settings to re-enable it")
                .font(.medium(size: 14))
                .foregroundColor(.cA0A7D2)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
            
            // Settings Button
            Button(action: openSettings) {
                Text("Settings")
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
    
    func openSettings() {
        EfficinacyCaller.shared.callHaptic()
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
        }
    }
}
