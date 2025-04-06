//
//  TabBarScreensView.swift
//  AuthenticatorApp
//
//  Created by Gideon Thackery on 25/02/2025.
//

import SwiftUI
import LocalAuthentication

enum TabbedItems: Int, CaseIterable {
    case home = 0, scan = 1, settings = 2
    
    var selectedImageName: String {
        switch self {
        case .home: return "wriejgiweff"
        case .scan: return "herijheridsf"
        case .settings: return "sgskdjfsdf"
        }
    }
    
    var deselectImageName: String {
        switch self {
        case .home: return "hfjhsdjfsdfsd"
        case .scan: return "herijheridsf"
        case .settings: return "weituweugd"
        }
    }
}

struct TabBarScreensView: View {
    
    @State private var isAuthenticated = false
    @State private var selectedTab = 0
    @StateObject private var appState = AppStateManager()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if isAuthenticated {
                TabView(selection: $selectedTab) {
                    FAHomeScreen(scanQRCodeVM: ScanQRCodeViewModel())
                        .tag(TabbedItems.home.rawValue)
                        .environmentObject(FAHomeViewModel())
                    
                    NavigationView {
                        ScanningScreen(scanQRCodeVM: ScanQRCodeViewModel(), selectedTab: $selectedTab)
                    }
                    .tag(TabbedItems.scan.rawValue)
                    .padding(.bottom)
                    
                    UserSettingsScreen(appState: appState)
                        .tag(TabbedItems.settings.rawValue)
                        .padding(.horizontal)
                }
                
                CustomTabBar(selectedTab: $selectedTab)
            } else {
                AuthView(authenticate: authenticate)
            }
        }
        .safeAreaPadding(.top, 50)
        .safeAreaPadding(.bottom, 28)
        .onAppear {
            authenticate()
        }
    }
    
    private func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if UserDefaults.standard.bool(forKey: "local"),
           context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            
            let reason = "Grant access to Face ID to enable biometrics to protect application"
            
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, _ in
                DispatchQueue.main.async {
                    isAuthenticated = success
                }
            }
        } else {
            isAuthenticated = true
        }
    }
}

// MARK: - Custom Components
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack {
            ForEach(TabbedItems.allCases, id: \.self) { item in
                Button {
                    EfficinacyCaller.shared.callHaptic()
                    selectedTab = item.rawValue
                } label: {
                    CustomTabItem(selectedImageName: item.selectedImageName,
                                  deselectImageName: item.deselectImageName,
                                  isActive: selectedTab == item.rawValue)
                }
            }
        }
        .frame(height: 78)
        .background(Color.white)
    }
}

struct CustomTabItem: View {
    let selectedImageName: String
    let deselectImageName: String
    let isActive: Bool
    
    var body: some View {
        HStack {
            Spacer()
            Image(isActive ? selectedImageName : deselectImageName)
            Spacer()
        }
    }
}

struct AuthView: View {
    let authenticate: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            Image(.adfafdasdasd)
            Spacer()
            Button(action: {
                EfficinacyCaller.shared.callHaptic()
                authenticate()
            }) {
                Image(.ashjfaijfqwf)
            }
            .padding(.bottom, 30)
        }
    }
}
