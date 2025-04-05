//
//  QuickActionsService.swift
//  AuthenticatorApp
//
//  Created by Gideon Thackery on 21/03/2025.
//

import SwiftUI

enum QuickAction: String, Hashable {
    case rating
    case question
    case help
}

class QuickActionsService: ObservableObject {
    static let instance = QuickActionsService()
    @Published var quickAction: QuickAction?
    
    func handleQuickAction(_ item: UIApplicationShortcutItem) {
        quickAction = QuickAction(rawValue: item.type)
    }
    
    func clearQuickAction() {
        quickAction = nil
    }
}
