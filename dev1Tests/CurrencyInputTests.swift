//
//  CurrencyInputTests.swift
//  dev1Tests
//

import Foundation
import Testing
@testable import dev1

struct CurrencyInputTests {
    @Test func parsesPlainWholeNumber() throws {
        let value = try CurrencyInput.parse("150").get()
        #expect(value == 150)
    }

    @Test func parsesDecimalAmount() throws {
        let value = try CurrencyInput.parse("150.50").get()
        #expect(value == Decimal(string: "150.50"))
    }

    @Test func trimsWhitespace() throws {
        let value = try CurrencyInput.parse("  75  ").get()
        #expect(value == 75)
    }

    @Test func rejectsEmptyInput() {
        #expect(CurrencyInput.parse("").isFailure(.empty))
        #expect(CurrencyInput.parse("   ").isFailure(.empty))
    }

    @Test func rejectsNonNumericInput() {
        #expect(CurrencyInput.parse("abc").isFailure(.notANumber))
    }

    @Test func rejectsZeroAndNegativeAmounts() {
        #expect(CurrencyInput.parse("0").isFailure(.notPositive))
        #expect(CurrencyInput.parse("-10").isFailure(.notPositive))
    }

    @Test func rejectsMoreThanTwoDecimalPlaces() {
        #expect(CurrencyInput.parse("10.999").isFailure(.tooManyDecimalPlaces))
    }

    @Test func rejectsAmountsAboveTheMaximum() {
        #expect(CurrencyInput.parse("1000000").isFailure(.tooLarge))
    }
}

private extension Result where Success == Decimal, Failure == CurrencyInput.ValidationError {
    func isFailure(_ expected: CurrencyInput.ValidationError) -> Bool {
        if case .failure(let error) = self {
            return error.errorDescription == expected.errorDescription
        }
        return false
    }
}
