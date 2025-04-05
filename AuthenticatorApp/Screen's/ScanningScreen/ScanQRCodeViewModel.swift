//
//  ScanQRCodeViewModel.swift
//  Authenticator
//
//  Created by Gideon Thackery on 06/12/2020.
//

import Foundation
import CoreData
import Combine

class ScanQRCodeViewModel: ObservableObject {
    let publisher = PassthroughSubject<FAAccountData, Never>();
    var cancellable: AnyCancellable?
    
    @Published var account: FAAccountData?
    @Published var showAddAccountView: Bool = false
    var addAccountVM: AddAccountViewModel?

    func foundBarcode(value: String) {
        guard let url = URL(string: value) else { return }
        
        do {
            let account = try FAAccountData(from: url)
            self.account = account
            publisher.send(account)
        } catch {
            print("Something went wrong \(error)")
        }
    }
}
