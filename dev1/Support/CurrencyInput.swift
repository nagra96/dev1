//
//  CurrencyInput.swift
//  dev1
//

import Foundation

/// Parses and validates free-text currency entry from a `TextField`.
///
/// `Decimal(string:)` assumes `.` as the decimal separator regardless of the
/// device's locale, which silently mis-parses input on devices where the
/// decimal pad shows a comma. Parsing with the current locale first (falling
/// back to `.` for people who type it anyway) avoids that class of bug.
enum CurrencyInput {
    /// Amounts above this are almost certainly a typo for a youth-sports fee
    /// or expense line item, not a real value someone meant to charge or log.
    static let maximumAmount = Decimal(100_000)

    enum ValidationError: LocalizedError {
        case empty
        case notANumber
        case notPositive
        case tooManyDecimalPlaces
        case tooLarge

        var errorDescription: String? {
            switch self {
            case .empty: return "Enter an amount."
            case .notANumber: return "Enter a valid dollar amount, like 150 or 150.00."
            case .notPositive: return "Amount must be greater than $0."
            case .tooManyDecimalPlaces: return "Amount can\u{2019}t have more than 2 decimal places."
            case .tooLarge: return "Amount must be less than \(maximumAmount.currencyString)."
            }
        }
    }

    static func parse(_ text: String) -> Result<Decimal, ValidationError> {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return .failure(.empty) }

        let localeFormatter = NumberFormatter()
        localeFormatter.numberStyle = .decimal
        localeFormatter.generatesDecimalNumbers = true
        // Parse the exact value the user typed rather than letting the
        // formatter round/truncate fraction digits; `tooManyDecimalPlaces`
        // below is what actually enforces the 2-decimal-place rule.
        localeFormatter.maximumFractionDigits = 20

        let value: Decimal
        if let number = localeFormatter.number(from: trimmed) as? NSDecimalNumber {
            value = number.decimalValue
        } else if let decimal = Decimal(string: trimmed) {
            value = decimal
        } else {
            return .failure(.notANumber)
        }

        guard value > 0 else { return .failure(.notPositive) }
        guard value <= maximumAmount else { return .failure(.tooLarge) }
        guard value.rounded(2) == value else { return .failure(.tooManyDecimalPlaces) }

        return .success(value)
    }
}

private extension Decimal {
    func rounded(_ scale: Int) -> Decimal {
        var result = Decimal()
        var mutableSelf = self
        NSDecimalRound(&result, &mutableSelf, scale, .plain)
        return result
    }
}
