//
//  HomeViewModel.swift
//  Authenticator
//
//  Created by Gideon Thackery on 21/03/2025.
//

import Foundation
import SwiftOTP
import CoreData
import Combine

class FAHomeViewModel: ObservableObject {
    var cancellable: AnyCancellable?
    
    @Published var accounts: [FAAccountData] = []
    
    @Published var showSettingsView: Bool = false
    @Published var showScanQRCodeView: Bool = false
    @Published var showAddAccountView: Bool = false
    
    init() {
        accounts = AccountService.shared.publisher.value
        
        cancellable = AccountService.shared.publisher.sink { accounts in
            self.accounts = accounts
        }
    }
    
    func delete(account: FAAccountData) {
        AccountService.shared.delete(account: account)
    }
}
