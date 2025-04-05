//
//  UserHomeScreen.swift
//  AuthenticatorApp
//
//  Created by Gideon Thackery on 25/02/2025.
//

import SwiftUI
import PhotosUI
import Vision

struct FAHomeScreen: View {
    // MARK: - State Variables
//    @State private var isPaywallPresented = false
    @State private var showPhotoLibrarySheet = false
    @State private var showDeleteSheet = false
    @State private var showToast = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var accountToDelete: FAAccountData?
    
    @ObservedObject var scanQRCodeVM: ScanQRCodeViewModel
    @EnvironmentObject var homeVM: FAHomeViewModel
    
    @Environment(\.openURL) var openUrl
    @AppStorage(AppStorageKeys.hasSeenSettingsPopover) private var hasSeenSettingsPopover: Bool = false
    
    private let pasteboard = UIPasteboard.general
    
    var body: some View {
        VStack {
            headerView()
            actionButtons()
            Spacer()
            List {
                ForEach(homeVM.accounts) { account in
                    FAHomeAccountRow(account: account) {
                        pasteboard.string = account.currentCode
                        EfficinacyCaller.shared.callHaptic()
                        withAnimation {
                            showToast = true
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button {
                            EfficinacyCaller.shared.callHaptic()
                            accountToDelete = account // Set the selected account
                            showDeleteSheet = true
                        } label: {
                            Image(.asdhasjkdasjd)
                        }
                    }
                    .tint(.white)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.white)
            }
            .overlay(Group {
                if homeVM.accounts.isEmpty {
                    Image(.ghjfhahdfasdas)
                        .padding(.bottom, 90)
                }
            })
            .listStyle(PlainListStyle())
            .background(.white)
            Spacer()
        }
        .background(Color.white)
        .showToast(isShowing: $showToast, message: "Copied", imageName: .efgqijfdqw)
//        .onAppear(perform: handleOnAppear)
        .fullScreenCover(isPresented: $scanQRCodeVM.showAddAccountView) {
            EnterCodeManuallyScreen(addAccountVM: scanQRCodeVM.addAccountVM ?? AddAccountViewModel())
        }
        .onReceive(scanQRCodeVM.publisher, perform: handleQRCodeScan)
        .sheet(isPresented: $showPhotoLibrarySheet) {
            PhotoLibraryAccessBottomSheet(isPresented: $showPhotoLibrarySheet)
                .presentationDetents([.height(320)])
                .presentationCornerRadius(34)
        }
        .sheet(isPresented: $showDeleteSheet) {
            DeleteItemBottomSheet(isPresented: $showDeleteSheet) {
                if let account = accountToDelete {
                    delete(account)
                }
            }
            .presentationDetents([.height(270)])
            .presentationCornerRadius(34)
        }
    }
    
    // MARK: - Header
    private func headerView() -> some View {
        Text("Authenticator")
            .padding(.top, 28)
            .font(.bold(size: 26))
            .foregroundStyle(.c090A36)
    }
    
    // MARK: - Action Buttons
    private func actionButtons() -> some View {
        HStack {
            scanQRButton()
            selectPhotoButton()
        }
    }
    
    private func scanQRButton() -> some View {
        Button(action: {
            EfficinacyCaller.shared.callHaptic()
            scanQRCodeVM.showAddAccountView = true
        }) {
            Image("sdklgsdfsdfd")
        }
    }
    
    private func selectPhotoButton() -> some View {
        return PhotosPicker(selection: $selectedItem, matching: .images) {
            Image(.ashfahfasjfa)
        }
        //        .onChange(of: selectedItem, perform: handleImageSelection)
        .onChange(of: selectedItem) { newItem in
            Task {
                await loadImage(from: newItem)
            }
        }
    }
    
    // MARK: - Actions
    private func handleOnAppear() {
        if !hasSeenSettingsPopover {
            requestPhotoLibraryPermission()
        }
    }
    
    private func handleQRCodeScan(_ account: FAAccountData) {
        scanQRCodeVM.addAccountVM = AddAccountViewModel(account: account)
        scanQRCodeVM.showAddAccountView = true
    }
    
    private func copyToClipboard(_ account: FAAccountData) {
        pasteboard.string = account.currentCode
        EfficinacyCaller.shared.callHaptic()
        withAnimation { showToast = true }
    }
    
    private func delete(_ account: FAAccountData) {
        withAnimation { homeVM.delete(account: account) }
    }
    
    private func handleImageSelection(_ newItem: PhotosPickerItem?) {
        Task { await loadImage(from: newItem) }
    }
    
    // MARK: - QR Code Scanning
    private func loadImage(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    detectQRCode(in: image)
                }
            }
        } catch {
            print("Failed to load image: \(error)")
        }
    }
    
    private func detectQRCode(in image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        let request = VNDetectBarcodesRequest { request, error in
            guard let results = request.results as? [VNBarcodeObservation], let barcode = results.first,
                  let qrCodeString = barcode.payloadStringValue else {
                return
            }
            DispatchQueue.main.async {
                scanQRCodeVM.foundBarcode(value: qrCodeString)
            }
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage)
        do {
            try handler.perform([request])
            selectedItem = nil
        } catch {
            print("Error scanning QR code: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Permissions
    private func requestPhotoLibraryPermission() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                hasSeenSettingsPopover = true
                handlePhotoPermission(status)
            }
        }
    }
    
    private func handlePhotoPermission(_ status: PHAuthorizationStatus) {
        if status == .restricted || status == .denied || status == .notDetermined {
            showPhotoLibrarySheet = true
        }
    }
}
