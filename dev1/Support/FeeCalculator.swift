//
//  FeeCalculator.swift
//  dev1
//

import Foundation

/// Computes processing fees for a payment collection. Pulled out of
/// `CollectPaymentView` so the math can be unit tested without SwiftUI
/// or SwiftData in the loop.
enum FeeCalculator {
    /// Standard card-not-present pricing: 2.9% + $0.30 (matches Stripe's
    /// published US card rate as of this writing).
    static let cardPercentageRate = Decimal(string: "0.029")!
    static let cardFixedFee = Decimal(string: "0.30")!

    /// Stripe's published US ACH debit rate: 0.8%, capped at $5.00.
    static let achPercentageRate = Decimal(string: "0.008")!
    static let achFeeCap = Decimal(5)

    enum Method {
        case card
        case ach
    }

    static func processingFee(on amount: Decimal, method: Method) -> Decimal {
        guard amount > 0 else { return 0 }
        switch method {
        case .card:
            return amount * cardPercentageRate + cardFixedFee
        case .ach:
            return min(amount * achPercentageRate, achFeeCap)
        }
    }

    /// - Returns: The amount to charge the payer, including the platform's
    ///   processing fee when `passFeeToPayer` is true.
    static func totalCharge(forBalance balance: Decimal, method: Method, passFeeToPayer: Bool) -> Decimal {
        let fee = processingFee(on: balance, method: method)
        return passFeeToPayer ? balance + fee : balance
    }
}
