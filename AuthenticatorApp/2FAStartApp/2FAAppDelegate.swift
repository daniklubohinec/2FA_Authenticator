//
//  2FAAppDelegate.swift
//  AuthenticatorApp
//
//  Created by Gideon Thackery on 21/03/2025.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
//        Keychain.logout()
        
        let sceneConfiguration = UISceneConfiguration(name: "Custom Configuration", sessionRole: connectingSceneSession.role)
        
        sceneConfiguration.delegateClass = SceneDelegate.self
        
        if let shortcutItem = options.shortcutItem {
            QuickActionsService.instance.handleQuickAction(shortcutItem)
        }
        
        return sceneConfiguration
    }
}
