//
//  AccountRow.swift
//  Authenticator
//
//  Created by Gideon Thackery on 21/03/2025.
//

import SwiftUI
import WidgetKit

struct FAHomeAccountRow: View {
    @ObservedObject var account: FAAccountData
    
    let pasteboard = UIPasteboard.general
    let onTap: () -> Void
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            HStack {
                accountInfo
                Spacer()
                if account.refreshMode == .automatic && account.counter == nil { // Show progress only for TOTP with automatic refresh
                    progressIndicator
                } else {
                    refreshButton
                }
                Spacer()
                otpCodeView
            }
            .padding()
        }
        .background(Color.cF3F7FF)
        .cornerRadius(20)
        .onReceive(timer, perform: updateTimer)
        .padding(.vertical, -6)
        .padding(.horizontal, 4)
    }
    
}

// MARK: - Subviews
private extension FAHomeAccountRow {
    @ViewBuilder
    var accountInfo: some View {
        VStack(alignment: .leading) {
            Text(account.issuer)
                .font(.bold(size: 18))
                .foregroundColor(.c090A36)
            Text(account.name)
                .font(.semiBold(size: 12))
                .foregroundColor(.cA0A7D2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    var progressIndicator: some View {
        TimerRowProgressView(progress: .constant(1 - Float(account.secondsUntilRefresh) / Float(account.timeInterval)), color: .constant(.c2B78FF))
            .frame(width: 28, height: 28)
            .padding(.vertical, 10)
    }
    
    @ViewBuilder
    var otpCodeView: some View {
        HStack {
            ForEach(Array(Array(account.currentCode ?? "").enumerated()), id: \.offset) { index, character in
                Text(String(character))
                    .font(.bold(size: 22))
                    .foregroundColor(.c2B78FF)
                    .padding(-4)
                
                if let code = account.currentCode, index == code.count / 2 - 1 {
                    Spacer().frame(width: 16) // Space in the middle of OTP
                }
            }
            Button {
                EfficinacyCaller.shared.callHaptic()
                onTap()
            } label: {
                Image(.askadaskjldas)
            }
            .frame(width: 20, height: 20)
            .buttonStyle(BorderedButtonStyle())
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    @ViewBuilder
    var refreshButton: some View {
        Button(action: {
            EfficinacyCaller.shared.callHaptic()
            account.refreshCode()
            WidgetCenter.shared.reloadAllTimelines()
        }) {
            Image(.qwuryqwyurqwr)
        }
        .frame(width: 28, height: 28)
        .padding(.vertical, 10)
        .buttonStyle(BorderedButtonStyle())
    }
}

// MARK: - Timer Updates
private extension FAHomeAccountRow {
    func updateTimer(_ : Timer.TimerPublisher.Output? = nil) {
        // Only update the widget if the code changes (handled by FAAccountData)
        if account.secondsUntilRefresh == account.timeInterval {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
