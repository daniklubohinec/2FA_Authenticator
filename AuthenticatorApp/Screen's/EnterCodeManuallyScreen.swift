//
//  EnterCodeManuallyScreen.swift
//  AuthenticatorApp
//
//  Created by Gideon Thackery on 15/03/2025.
//

import SwiftUI
import Foundation
import Security

public class Keychain: NSObject {
    public class func logout()  {
        let secItemClasses =  [
            kSecClassGenericPassword,
            kSecClassInternetPassword,
            kSecClassCertificate,
            kSecClassKey,
            kSecClassIdentity,
        ]
        for itemClass in secItemClasses {
            let spec: NSDictionary = [kSecClass: itemClass]
            SecItemDelete(spec)
        }
    }
}

struct EnterCodeManuallyScreen: View {
    @State private var selectedOption = "Time"
    @State private var serviceName = ""
    @State private var email = ""
    @State private var secretKey = ""
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var addAccountVM: AddAccountViewModel
    
    @State private var paywall: PaywallModel?
    
    @EnvironmentObject var purchaseService: PurchaseService
    @EnvironmentObject var globalPWState: GlobalPWState
    
    init(addAccountVM: AddAccountViewModel = AddAccountViewModel()) {
        self.addAccountVM = addAccountVM
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                HeaderView(title: "Enter key", onClose: { dismissScreen() })
                
                // Segmented control for Time/Counter
                SegmentedControl(selectedOption: $selectedOption)
                    .onChange(of: selectedOption) { newValue in
                        if newValue == "Time" {
                            addAccountVM.timeInterval = 30
                            addAccountVM.counter = nil
                        } else {
                            addAccountVM.timeInterval = 0
                            addAccountVM.counter = 0
                        }
                    }
                
                VStack(alignment: .leading, spacing: 28) {
                    InputField(title: "Service name", text: $addAccountVM.issuer, placeholder: "e.g. Google")
                    InputField(title: "Email or username", text: $addAccountVM.name, placeholder: "e.g. johndoe@gmail.com").keyboardType(.emailAddress)
                    InputField(title: "Secret key", text: $addAccountVM.secret, placeholder: "e.g. OPhsjd8382PPJ")
                }
                .padding()
                
                Spacer()
                
                GradientButton(title: "Add") {
//                                        addAccountVM.add()
//                                        dismissScreen()
                    startAutomation()
                }
                .disabled(!addAccountVM.formIsValid)
                .padding(.horizontal, 20)
            }
            .hideKeyboardWhenTappedAround()
            .fullScreenCover(item: $paywall) { pw in
                InAppPaywallView(paywall: pw, appState: AppStateManager(), completed: !purchaseService.isFV)
            }
            .onDisappear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    
                }
            }
        }
    }
    
    /// Dismiss the screen and reset the form
    private func dismissScreen() {
        dismiss()
        resetForm()
    }
    
    /// Reset input fields when screen is dismissed or reopened
    private func resetForm() {
        selectedOption = "Time"
        serviceName = ""
        email = ""
        secretKey = ""
        addAccountVM.issuer = ""
        addAccountVM.name = ""
        addAccountVM.secret = ""
    }
    
    private func startAutomation() {
        if purchaseService.hasPremium {
            addAccountVM.add()
            dismiss()
        } else if let appPW = purchaseService.appPaywall {
            globalPWState.paywallData.send(appPW)
        } else {
            //no paywalls loaded, show alert
            globalPWState.paywallsNotLoadedAlert = true
        }
    }
}

// MARK: - Header View
struct HeaderView: View {
    var title: String
    var onClose: () -> Void
    
    var body: some View {
        ZStack {
            Text(title)
                .font(.bold(size: 26))
                .foregroundColor(.c090A36)
                .padding(.top, 20)
            HStack {
                Spacer()
                Button(action: {
                    EfficinacyCaller.shared.callHaptic()
                    onClose()
                }) { // Call onClose() inside a closure
                    Image(.gqejqjfasd)
                }
                .padding(.top, 20)
                .padding(.trailing, 20)
            }
        }
    }
}

// MARK: - Segmented Control
struct SegmentedControl: View {
    @Binding var selectedOption: String
    
    var body: some View {
        HStack {
            SegmentButton(title: "Time", isSelected: selectedOption == "Time") {
                selectedOption = "Time"
                
            }
            SegmentButton(title: "Counter", isSelected: selectedOption == "Counter") {
                selectedOption = "Counter"
            }
        }
        .frame(width: 205, height: 50)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .foregroundColor(.cF3F7FF)
        )
    }
}

// MARK: - Gradient Button
struct GradientButton: View {
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.bold(size: 18))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 68)
                .background(
                    LinearGradient(colors: [.c4E8EFF, .c3069FE], startPoint: .top, endPoint: .bottom)
                        .cornerRadius(32)
                )
        }
    }
}

// MARK: - Segment Button
struct SegmentButton: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
            EfficinacyCaller.shared.callHaptic()
        } label: {
            Text(title)
                .font(.bold(size: 14))
                .foregroundColor(isSelected ? .white : .c090A36)
                .frame(width: 102, height: 50)
                .background(
                    Group {
                        if isSelected {
                            LinearGradient(colors: [.c4E8EFF, .c3069FE], startPoint: .top, endPoint: .bottom)
                                .clipShape(RoundedRectangle(cornerRadius: 32))
                        } else {
                            Color.clear
                        }
                    }
                )
                .cornerRadius(25)
        }
        .padding(-4)
    }
}

// MARK: - Input Field
struct InputField: View {
    var title: String
    @Binding var text: String
    var placeholder: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.bold(size: 20))
                .foregroundColor(.c090A36)
            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.cA0A7D2))
                .onSubmit {
                    EfficinacyCaller.shared.callHaptic()
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 32).fill(.cF3F7FF))
                .foregroundColor(.c090A36)
                .submitLabel(.done)
        }
    }
}

extension View {
    func hideKeyboardWhenTappedAround() -> some View  {
        EfficinacyCaller.shared.callHaptic()
        return self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                            to: nil, from: nil, for: nil)
        }
    }
}
