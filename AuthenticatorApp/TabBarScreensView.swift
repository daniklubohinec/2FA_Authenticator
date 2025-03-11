//
//  TabBarScreensView.swift
//  AuthenticatorApp
//
//  Created by Danik Lubohinec on 25/02/2025.
//

import SwiftUI
import LocalAuthentication

enum TabbedItems: Int, CaseIterable {
    case home = 0
    case scan
    case settings
    
    var selectedImageName: String {
        switch self {
        case .home:
            return "wriejgiweff"
        case .scan:
            return "herijheridsf"
        case .settings:
            return "sgskdjfsdf"
        }
    }
    
    var deselectImageName: String {
        switch self {
        case .home:
            return "hfjhsdjfsdfsd"
        case .scan:
            return "herijheridsf"
        case .settings:
            return "weituweugd"
        }
    }
}

struct TabBarScreensView: View {
    
    @State private var isAuthentificated = false
    
    @State var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if isAuthentificated {
                TabView(selection: $selectedTab) {
                    UserHomeScreen()
                        .tag(0)
                    
                    ScanningScreen()
                        .tag(1)
                    
                    UserSettingsScreen(appState: AppStateManager())
                        .tag(2)
                        .padding(.horizontal)
                }
                
                ZStack{
                    HStack{
                        ForEach((TabbedItems.allCases), id: \.self){ item in
                            Button {
                                EfficinacyCaller.shared.callHaptic()
                                selectedTab = item.rawValue
                            } label: {
                                CustomTabItem(selectedImageName: item.selectedImageName, deselectImageName: item.deselectImageName, isActive: (selectedTab == item.rawValue))
                            }
                        }
                    }
                }
            } else {
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
        .onAppear {
            authenticate()
        }
    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        let isFaceIDEnabled = UserDefaults.standard.bool(forKey: "local")
        
        if isFaceIDEnabled {
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                // it's possible, so go ahead and use it
                let reason = "Grant access to Face ID to enable biometrics to protect application"
                
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                    // authentication has now completed
                    if success {
                        // authenticated successfully
                        isAuthentificated = true
                    } else {
                        // there was a problem
                    }
                }
            } else {
                // no biometrics
            }
        } else {
            isAuthentificated = true
        }
    }
}

#Preview {
    TabBarScreensView()
    //        .modelContainer(for: Item.self, inMemory: true)
}

extension TabBarScreensView {
    func CustomTabItem(selectedImageName: String, deselectImageName: String, isActive: Bool) -> some View{
        HStack(spacing: 10){
            Spacer()
            Image(isActive ? selectedImageName : deselectImageName)
            Spacer()
        }
        .frame(height: 78)
        .background(Color.white)
    }
}
