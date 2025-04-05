//
//  GlobalPWState.swift
//  AuthenticatorApp
//
//  Created by Gideon Thackery on 10/03/2025.
//

import Combine

class GlobalPWState: ObservableObject {
    let paywallData = PassthroughSubject<PaywallModel, Never>()
    let closeOnbPaywall = PassthroughSubject<Void, Never>()
    @Published var paywallsNotLoadedAlert = false
}
