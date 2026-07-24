//
//  FeeCalculatorTests.swift
//  dev1Tests
//

import Testing
@testable import dev1

struct FeeCalculatorTests {
    @Test func cardFeeMatchesPublishedRate() {
        // $150.00 * 2.9% + $0.30 = $4.65
        let fee = FeeCalculator.processingFee(on: 150, method: .card)
        #expect(fee == Decimal(string: "4.65"))
    }

    @Test func achFeeMatchesPublishedRate() {
        // $150.00 * 0.8% = $1.20
        let fee = FeeCalculator.processingFee(on: 150, method: .ach)
        #expect(fee == Decimal(string: "1.20"))
    }

    @Test func achFeeIsCappedAtFiveDollars() {
        // $10,000 * 0.8% = $80, which is above the $5 cap.
        let fee = FeeCalculator.processingFee(on: 10_000, method: .ach)
        #expect(fee == FeeCalculator.achFeeCap)
    }

    @Test func zeroBalanceHasNoFee() {
        #expect(FeeCalculator.processingFee(on: 0, method: .card) == 0)
        #expect(FeeCalculator.processingFee(on: 0, method: .ach) == 0)
    }

    @Test func totalChargeIncludesFeeOnlyWhenPassedThrough() {
        let balance = Decimal(150)
        let withFee = FeeCalculator.totalCharge(forBalance: balance, method: .card, passFeeToPayer: true)
        let withoutFee = FeeCalculator.totalCharge(forBalance: balance, method: .card, passFeeToPayer: false)

        #expect(withFee == balance + FeeCalculator.processingFee(on: balance, method: .card))
        #expect(withoutFee == balance)
    }
}
