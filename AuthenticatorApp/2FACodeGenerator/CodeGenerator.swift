//
//  CodeGenerator.swift
//  Authenticator
//
//  Created by Gideon Thackery on 21/03/2025.
//

import Foundation
import SwiftOTP

class CodeGenerator {
    public static let shared = CodeGenerator()
    private(set) var digits: Int
    private(set) var timeInterval: Int
    private(set) var counter: Int64? // Add counter for HOTP
    private(set) var algorithm: OTPAlgorithm
    
    init(digits: Int = 6, timeInterval: Int = 30, counter: Int64? = nil, algorithm: FAAlgorithm = .sha1) {
        self.digits = digits
        self.timeInterval = timeInterval
        self.counter = counter
        
        switch algorithm {
        case .sha1:
            self.algorithm = OTPAlgorithm.sha1
        case .sha256:
            self.algorithm = OTPAlgorithm.sha256
        case .sha512:
            self.algorithm = OTPAlgorithm.sha512
        }
    }
    
    func generate(forSecret: String, counterValue: Int64? = nil) -> String? {
        guard let data = base32DecodeToData(forSecret) else { return nil }
        
        if let counter = counterValue ?? self.counter { // HOTP mode
            guard let hotp = HOTP(secret: data, digits: self.digits, algorithm: self.algorithm) else { return nil }
            return hotp.generate(counter: UInt64(counter))
        } else { // TOTP mode
            guard let totp = TOTP(secret: data, digits: self.digits, timeInterval: self.timeInterval, algorithm: self.algorithm) else { return nil }
            return totp.generate(time: Date())
        }
    }
}
