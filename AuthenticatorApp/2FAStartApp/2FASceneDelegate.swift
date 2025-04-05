//
//  2FASceneDelegate.swift
//  AuthenticatorApp
//
//  Created by Gideon Thackery on 21/03/2025.
//

import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        QuickActionsService.instance.handleQuickAction(shortcutItem)
    }
}
