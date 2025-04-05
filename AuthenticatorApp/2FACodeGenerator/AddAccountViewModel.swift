//
//  AddAccountViewModel.swift
//  Authenticator
//
//  Created by Gideon Thackery on 21/03/2025.
//

import Foundation
import CoreData
import SwiftKeychainWrapper
import SwiftOTP
import Combine

class AddAccountViewModel: ObservableObject {
    @Published var issuer: String
    @Published var name: String
    @Published var secret: String
    
    @Published var showAdvancedOptions: Bool
    @Published var algorithm: FAAlgorithm
    @Published var digits: Int
    @Published var timeInterval: Int
    @Published var counter: Int64? // Add counter for HOTP
    @Published var refreshMode: RefreshMode // Add refresh mode
    
    let publisher = PassthroughSubject<FAAccountData, Never>()
    
    var formIsValid: Bool {
        // Ensure required fields are non-empty and secret is valid Base32
        if issuer.isEmpty || name.isEmpty || secret.isEmpty || base32DecodeToData(secret) == nil {
            return false
        }
        // For TOTP, ensure timeInterval is positive; for HOTP, counter can be 0 or more
        if counter == nil && timeInterval <= 0 {
            return false
        }
        return true
    }
    
    init(issuer: String = "", name: String = "", secret: String = "", algorithm: FAAlgorithm = .sha1, digits: Int = 6, timeInterval: Int = 30, counter: Int64? = nil, refreshMode: RefreshMode = .automatic) {
        self.issuer = issuer
        self.name = name
        self.secret = secret
        self.showAdvancedOptions = false
        self.algorithm = algorithm
        self.digits = digits
        self.timeInterval = timeInterval
        self.counter = counter
        self.refreshMode = refreshMode
    }
    
    convenience init(account: FAAccountData) {
        self.init(
            issuer: account.issuer,
            name: account.name,
            secret: account.secret,
            algorithm: account.algorithm,
            digits: account.digits,
            timeInterval: account.timeInterval,
            counter: account.counter,
            refreshMode: account.refreshMode
        )
    }
    
    func add() {
        let account = FAAccountData(
            issuer: self.issuer,
            name: self.name,
            secret: self.secret,
            digits: self.digits,
            timeInterval: self.timeInterval,
            counter: self.counter,
            algorithm: self.algorithm,
            refreshMode: self.refreshMode
        )
        
        AccountService.shared.save(account: account)
        
        publisher.send(account)
    }
}
