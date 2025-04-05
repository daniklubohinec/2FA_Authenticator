//
//  Account.swift
//  Authenticator
//
//  Created by Gideon Thackery on 21/03/2025.
//

import Foundation
import SwiftOTP
import CoreData

// MARK: - Refresh Mode Enum
enum RefreshMode: String, Codable {
    case manual, automatic
}

// MARK: - FAAccountData Model
class FAAccountData: ObservableObject, Codable, Identifiable {
    // MARK: - Properties
    var id: UUID
    var issuer: String
    var name: String
    var secret: String
    var digits: Int
    var timeInterval: Int
    var counter: Int64?
    var algorithm: FAAlgorithm
    var refreshMode: RefreshMode
    
    @Published var currentCode: String? // Transient, not encoded
    @Published var secondsUntilRefresh: Int // Transient, not encoded
    
    private var timer: Timer?
    
    // MARK: - Coding Keys
    private enum CodingKeys: String, CodingKey {
        case id, issuer, name, secret, digits, timeInterval, counter, algorithm, refreshMode
    }
    
    // MARK: - Initializers
    init(
        issuer: String,
        name: String,
        secret: String,
        digits: Int = 6,
        timeInterval: Int = 30,
        counter: Int64? = nil,
        algorithm: FAAlgorithm = .sha1,
        refreshMode: RefreshMode = .automatic
    ) {
        self.id = UUID()
        self.issuer = issuer
        self.name = name
        self.secret = secret
        self.digits = digits
        self.timeInterval = timeInterval
        self.counter = counter
        self.algorithm = algorithm
        self.refreshMode = refreshMode
        self.secondsUntilRefresh = timeInterval
        self.currentCode = nil
        
        setupCodeGeneration()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        issuer = try container.decode(String.self, forKey: .issuer)
        name = try container.decode(String.self, forKey: .name)
        secret = try container.decode(String.self, forKey: .secret)
        digits = try container.decode(Int.self, forKey: .digits)
        timeInterval = try container.decode(Int.self, forKey: .timeInterval)
        counter = try container.decodeIfPresent(Int64.self, forKey: .counter)
        algorithm = try container.decode(FAAlgorithm.self, forKey: .algorithm)
        refreshMode = try container.decode(RefreshMode.self, forKey: .refreshMode)
        
        self.secondsUntilRefresh = timeInterval
        self.currentCode = nil
        
        setupCodeGeneration()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(issuer, forKey: .issuer)
        try container.encode(name, forKey: .name)
        try container.encode(secret, forKey: .secret)
        try container.encode(digits, forKey: .digits)
        try container.encode(timeInterval, forKey: .timeInterval)
        try container.encodeIfPresent(counter, forKey: .counter)
        try container.encode(algorithm, forKey: .algorithm)
        try container.encode(refreshMode, forKey: .refreshMode)
    }
    
    // MARK: - Setup
    private func setupCodeGeneration() {
        generateCode()
        if refreshMode == .automatic, counter == nil {
            startRefreshTimer()
        }
    }
    
    // MARK: - Code Generation
    func generateCode() -> String? {
        let generator = CodeGenerator(digits: digits, timeInterval: timeInterval, counter: counter, algorithm: algorithm)
        let code = generator.generate(forSecret: secret, counterValue: counter)
        
        if counter != nil { counter! += 1 } // Increment for HOTP
        
        self.currentCode = code
        self.secondsUntilRefresh = calculateSecondsUntilRefresh()
        return code
    }
    
    private func calculateSecondsUntilRefresh() -> Int {
        return counter == nil ? timeInterval - Int(Date().timeIntervalSince1970) % timeInterval : 0
    }
    
    // MARK: - Timer Management
    private func startRefreshTimer() {
        stopRefreshTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.secondsUntilRefresh = self.calculateSecondsUntilRefresh()
            if self.secondsUntilRefresh == self.timeInterval {
                self.generateCode()
            }
        }
    }
    
    func stopRefreshTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func refreshCode() {
        //        generateCode()
        if refreshMode == .automatic, counter == nil {
            startRefreshTimer()
        } else {
            generateCode()
        }
    }
    
    deinit {
        stopRefreshTimer()
    }
}

// MARK: - URL-Based Initialization
extension FAAccountData {
    convenience init(from url: URL) throws {
        let queryItems = url.queryItemsData
        
        guard url.scheme == "otpauth", let host = url.host, let secret = queryItems?[FAAccountKey.secret.rawValue] else {
            throw FAAccountError.invalidURL
        }
        
        let splitName = url.path.dropFirst().split(separator: ":")
        let name = splitName.last?.trimmingCharacters(in: .whitespacesAndNewlines)
        let issuer = splitName.count > 1 ? splitName.first?.trimmingCharacters(in: .whitespacesAndNewlines) : nil
        
        let digits = Int(queryItems?[FAAccountKey.digits.rawValue] ?? "6") ?? 6
        let algorithm = FAAlgorithm(rawValue: queryItems?[FAAccountKey.algorithm.rawValue] ?? FAAlgorithm.sha1.rawValue) ?? .sha1
        
        let (timeInterval, counter, refreshMode): (Int, Int64?, RefreshMode) = host == FAGeneratorAlgorithm.totp.rawValue
        ? (Int(queryItems?[FAAccountKey.period.rawValue] ?? "30") ?? 30, nil, .automatic)
        : (0, Int64(queryItems?["counter"] ?? "0"), .manual)
        
        self.init(issuer: issuer ?? "", name: name ?? "", secret: secret, digits: digits, timeInterval: timeInterval, counter: counter, algorithm: algorithm, refreshMode: refreshMode)
    }
}

// MARK: - Supporting Enums
enum FAGeneratorAlgorithm: String {
    case totp
}

enum FAAccountKey: String {
    case issuer, name, secret, digits, algorithm, period, counter
}

enum FAAccountError: Error {
    case invalidURL, invalidSecret, invalidIssuer, invalidName
}

enum FAAlgorithm: String, CaseIterable, Codable {
    case sha1 = "SHA1", sha256 = "SHA256", sha512 = "SHA512"
}
