//
//  SubscriptionService.swift
//  AuthenticatorApp
//
//  Created by Gideon Thackery on 10/03/2025.
//

import Foundation
import Adapty
import SwiftUI

class PurchaseService: ObservableObject {
    //    static var shared  = PurchaseService()
    @Published var hasPremium: Bool = false
    @Published var paywallsLoaded: Bool = false
    @Published var processing: Bool = false
    @Published var processingRestore: Bool = false
    @Published var products: [AdaptyPaywallProduct] = []
    @Published var appPaywall: PaywallModel?
    
    @Published var isFV: Bool = true
    
    let appGroupDefaults = UserDefaults(suiteName: "group.com.authenticator.thackery")
    let subscriptionKey: String = "subscriptionStatus"
    
    
    init() {
        let key = Bundle.main.infoDictionary?["AdaptyKey"] as? String ?? ""
        Adapty.activate(key)
        print("Adapty инициализирован")
    }
    
    @MainActor
    func checkPurchases() async {
        if let currentStatus = loadSubscriptionStatus(), currentStatus.expirationDate > Date.now {
            hasPremium = true
            print("Subscription status loaded from App Group, active")
        } else {
            do {
                let profile = try await Adapty.getProfile()
                hasPremium = profile.accessLevels["premium"]?.isActive ?? false
                if hasPremium, let expiration = profile.accessLevels["premium"]?.expiresAt {
                    saveSubscriptionStatus(expiration: expiration)
                } else {
                    removeSubscriptionStatus()
                }
                print("Premium info received: \(hasPremium)")
            } catch {
                hasPremium = false
                print("Error while checking premium status: \(error.localizedDescription)")
            }
        }
    }
    
    func getPaywalls() async {
        do {
            let paywall = try await Adapty.getPaywall(placementId: "premium_access")
            let data = parsePaywallConfigs(paywall: paywall)
            guard let data else { return }
            try await processPaywallData(paywall: paywall, data: data)
            
            print("Products: \(products.map { $0.vendorProductId })")
        } catch {
            print("Error while getting paywalls: \(error.localizedDescription)")
        }
    }
    
    private func parsePaywallConfigs(paywall: AdaptyPaywall) -> Data? {
        guard let json = paywall.remoteConfig?.jsonString,
              let data = json.data(using: .utf8) else { return nil }
        return data
    }
    
    @MainActor
    private func processPaywallData(paywall: AdaptyPaywall,
                                    data: Data) async throws {
        
        let configuration = try JSONDecoder().decode(AdaptyConfig.self, from: data)
        let productList: [AdaptyPaywallProduct] = try await Adapty.getPaywallProducts(paywall: paywall)
        
        isFV = !configuration.prerelease
        
        print("_____\(configuration.prerelease)")
        
        if let weekly = productList.first(where: { $0.vendorProductId.contains("699_weekly_auth") }),
           let monthly = productList.first(where: { $0.vendorProductId.contains("1999_monthly_auth") }),
           let yearly = productList.first(where: { $0.vendorProductId.contains("4999_annual_auth") }) {
            appPaywall = PaywallModel(config: configuration,
                                      weeklyProduct: weekly,
                                      monthlyProduct: monthly,
                                      yearlyProduct: yearly)
            
        }
    }
    
    @MainActor
    func makePurchase(product: AdaptyPaywallProduct) async {
        do {
            self.processing = true
            let result = try await Adapty.makePurchase(product: product)
            DispatchQueue.main.async {
                self.hasPremium = result.profile?.accessLevels["premium"]?.isActive ?? false
                self.processing = false
            }
            
            if hasPremium, let expiration = result.profile?.accessLevels["premium"]?.expiresAt {
                saveSubscriptionStatus(expiration: expiration)
            }
            print("Покупка завершена, статус подписки: \(hasPremium)")
        } catch {
            print("Ошибка при покупке: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.processing = false
            }
        }
    }
    
    @MainActor
    func restorePurchases() async {
        do {
            self.processingRestore = true
            let profile = try await Adapty.restorePurchases()
            DispatchQueue.main.async {
                self.hasPremium = profile.accessLevels["premium"]?.isActive ?? false
                self.processingRestore = false
            }
            
            if hasPremium, let expiration = profile.accessLevels["premium"]?.expiresAt {
                saveSubscriptionStatus(expiration: expiration)
            }
            print("Восстановление покупок завершено, статус подписки: \(hasPremium)")
        } catch {
            print("Ошибка при восстановлении покупок: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.processingRestore = false
            }
        }
    }
    
    private func saveSubscriptionStatus(expiration: Date) {
        let info = SubscriptionInfo(isActive: hasPremium, expirationDate: expiration)
        do {
            let data = try JSONEncoder().encode(info)
            appGroupDefaults?.set(data, forKey: subscriptionKey)
        } catch {
            print("Ошибка при сохранении статуса подписки: \(error.localizedDescription)")
        }
    }
    
    private func loadSubscriptionStatus() -> SubscriptionInfo? {
        if let data = appGroupDefaults?.data(forKey: subscriptionKey) {
            do {
                return try JSONDecoder().decode(SubscriptionInfo.self, from: data)
            } catch {
                print("Ошибка при загрузке статуса подписки: \(error.localizedDescription)")
            }
        }
        return nil
    }
    
    private func removeSubscriptionStatus() {
        appGroupDefaults?.removeObject(forKey: subscriptionKey)
        print("Статус подписки успешно удален")
    }
}

struct SubscriptionInfo: Codable {
    let isActive: Bool
    let expirationDate: Date
}

struct PaywallModel: Identifiable/*, Equatable*/ {
    var config: AdaptyConfig
    var weeklyProduct: AdaptyPaywallProduct
    var monthlyProduct: AdaptyPaywallProduct
    var yearlyProduct: AdaptyPaywallProduct
    
    let id = UUID()
    
    //     static func == (lhs: PaywallModel, rhs: PaywallModel) -> Bool {
    //         return lhs.id == rhs.id
    //     }
}

struct AdaptyConfig: Decodable {
    var prerelease: Bool
    var fullPriceTitle: String?
}

extension String {
    
    public static var empty: String {
        ""
    }
}

extension PurchaseService {
    func calculateWeeklyPrice(from priceString: String, weeks: Double, isPer: Bool = false) -> String {
        
        let numberString = priceString.components(separatedBy: CharacterSet(charactersIn: "0123456789.,").inverted).joined()
        let currencySymbol = priceString.components(separatedBy: CharacterSet(charactersIn: "0123456789., /")).joined().trimmingCharacters(in: .whitespacesAndNewlines)
        
        let decimalSeparator = numberString.contains(",") ? "," : "."
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        //        numberFormatter.currencySymbol = currencySymbol
        numberFormatter.locale = Locale.current
        numberFormatter.decimalSeparator = decimalSeparator
        numberFormatter.maximumFractionDigits = 2
        
        guard let price = numberFormatter.number(from: numberString) else { return "" }
        
        let weeklyPrice = price.doubleValue / weeks
        
        //        numberFormatter.numberStyle = .currency
        let isDollarCurrency = currencySymbol == "$"
        let periodSeparator = isPer ? " per " : "/"
        
        if let formattedPrice = numberFormatter.string(from: NSNumber(value: weeklyPrice)) {
            let priceString = isDollarCurrency ? "\(currencySymbol)\(formattedPrice)" : "\(formattedPrice) \(currencySymbol)"
            return "\(priceString)\(periodSeparator)week"
        } else {
            return ""
        }
    }
    
    func calculateDiscountPercentage(weeklyPrice: String?, yearlyPrice: String?) -> String {
        guard let weeklyPriceString = weeklyPrice,
              let yearlyPriceString = yearlyPrice
        else {
            return ""
        }
        
        func extractPrice(from priceString: String) -> Double? {
            let numberString = priceString.components(separatedBy: CharacterSet(charactersIn: "0123456789.,").inverted).joined()
            let currencySymbol = priceString.components(separatedBy: CharacterSet(charactersIn: "0123456789., /")).joined().trimmingCharacters(in: .whitespacesAndNewlines)
            let decimalSeparator = numberString.contains(",") ? "," : "."
            
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.currencySymbol = currencySymbol
            numberFormatter.locale = Locale.current
            numberFormatter.decimalSeparator = decimalSeparator
            numberFormatter.maximumFractionDigits = 2
            
            if let priceNumber = numberFormatter.number(from: numberString) {
                return priceNumber.doubleValue
            } else {
                return nil
            }
        }
        
        guard let weeklyPriceValue = extractPrice(from: weeklyPriceString),
              let yearlyPriceValue = extractPrice(from: yearlyPriceString) else {
            return ""
        }
        
        let yearlyCostFromWeekly = weeklyPriceValue * 52.0
        
        let discountAmount = yearlyCostFromWeekly - yearlyPriceValue
        
        let discountPercentage = (discountAmount / yearlyCostFromWeekly) * 100.0
        
        let flooredDiscountPercentage = floor(discountPercentage)
        
        // Возвращаем процент скидки в виде строки без десятичных знаков
        return String(format: "%.0f", flooredDiscountPercentage)
    }
}
