//
//  ScanningScreen.swift
//  AuthenticatorApp
//
//  Created by Gideon Thackery on 25/02/2025.
//

import SwiftUI
import CarBode
import AVFoundation

struct ScanningScreen: View {
    
    @StateObject var cameraManager = CameraManager()
    @State private var isFlashOn = false
    @State private var showSheet = false
    
    @ObservedObject var scanQRCodeVM: ScanQRCodeViewModel
    
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack {
            Text("Scanner")
                .padding(.top, 28)
                .font(.bold(size: 26))
                .foregroundStyle(.c090A36)
            
            ZStack {
                if !scanQRCodeVM.showAddAccountView {
                    CBScanner(
                        supportBarcode: .constant([.qr]), torchLightIsOn: $isFlashOn,
                        scanInterval: .constant(2.0)
                    ) { scanQRCodeVM.foundBarcode(value: $0.value) }
                        .background(.black)
                        .cornerRadius(38)
                }
                
                Image(.hwfjfasdkasdas)
                
                // Flash Button
                VStack {
                    HStack {
                        Spacer()
                        flashButton
                    }
                    .padding(20)
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .onAppear {
            //            cameraManager.requestPermission()
            checkUserCameraAccess()
            print("Camera Permission:", cameraManager.permissionGranted)
        }
        //        .onReceive(scanQRCodeVM.publisher) { account in
        //            scanQRCodeVM.addAccountVM = AddAccountViewModel(account: account)
        //                        selectedTab = 0
        //                        CustomTabBar(selectedTab: $selectedTab)
        //            scanQRCodeVM.showAddAccountView = true
        //        }
        .onReceive(scanQRCodeVM.publisher) { account in
            scanQRCodeVM.addAccountVM = AddAccountViewModel(account: account)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                selectedTab = TabbedItems.home.rawValue
            }
            
            if selectedTab == TabbedItems.home.rawValue {
                scanQRCodeVM.showAddAccountView = false
            } else {
                scanQRCodeVM.showAddAccountView = true
            }
            
        }
        .sheet(isPresented: $showSheet) {
            CameraAccessBottomSheet(isPresented: $showSheet)
                .presentationDetents([.height(320)])
                .presentationCornerRadius(34)
        }
        .fullScreenCover(isPresented: $scanQRCodeVM.showAddAccountView) {
            if let addAccountVM = scanQRCodeVM.addAccountVM {
                EnterCodeManuallyScreen(addAccountVM: addAccountVM)
            } else {
                EnterCodeManuallyScreen()
            }
        }
        .onDisappear {
            print("____")
        }
        Spacer()
    }
    
    private func checkUserCameraAccess() {
        if AVCaptureDevice.authorizationStatus(for: .video) != .notDetermined {
            if AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
                DispatchQueue.main.async {
                    showSheet = true
                }
            }
        }
    }
    
    // Flash Button
    private var flashButton: some View {
        Button(action: {
            isFlashOn.toggle()
        }) {
            Image(isFlashOn ? .asjidaisodjsFalse : .asjdasdadsTrue)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
        }
    }
}

// Camera Manager Class
class CameraManager: ObservableObject {
    @Published var permissionGranted = true
    
    func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { accessGranted in
            DispatchQueue.main.async {
                self.permissionGranted = accessGranted
            }
        }
    }
}
