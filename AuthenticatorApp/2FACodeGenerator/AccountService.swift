//
//  AccountService.swift
//  Authenticator
//
//  Created by Gideon Thackery on 21/03/2025.
//

import Foundation
import SwiftKeychainWrapper
import Combine

class AccountService {
    static let shared = AccountService()
    
    let publisher = CurrentValueSubject<[FAAccountData], Never>([])
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let keychain = KeychainWrapper.standard
    
    init() {
        publisher.send(get())
    }
    
    /// Retrieves stored accounts from Keychain.
    func get() -> [FAAccountData] {
        guard let data = keychain.data(forKey: .accounts) else { return [] }
        
        do {
            let accounts = try decoder.decode([FAAccountData].self, from: data)
            publisher.send(accounts)
            return accounts
        } catch {
            print("Error decoding accounts: \(error)")
            return []
        }
    }
    
    /// Saves a new account to Keychain.
    @discardableResult
    func save(account: FAAccountData) -> Bool {
        var accounts = get()
        accounts.append(account)
        return save(accounts: accounts)
    }
    
    /// Deletes a specific account from Keychain.
    @discardableResult
    func delete(account: FAAccountData) -> Bool {
        var accounts = get()
        
        if let index = accounts.firstIndex(where: { $0.id == account.id }) {
            accounts.remove(at: index)
            return save(accounts: accounts)
        }
        
        return false
    }
    
    /// Deletes all accounts from Keychain.
    @discardableResult
    func deleteAll() -> Bool {
        return save(accounts: [])
    }
    
    /// Saves the given list of accounts to Keychain.
    @discardableResult
    private func save(accounts: [FAAccountData]) -> Bool {
        do {
            let data = try encoder.encode(accounts)
            let isSuccess = keychain.set(data, forKey: KeychainWrapper.Key.accounts.rawValue, withAccessibility: .afterFirstUnlock)
            publisher.send(accounts)
            
            print("Saved \(accounts.count) accounts to keychain.")
            return isSuccess
        } catch {
            print("Error encoding accounts: \(error)")
            return false
        }
    }
}
