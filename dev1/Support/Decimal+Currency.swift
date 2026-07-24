//
//  Decimal+Currency.swift
//  dev1
//

import Foundation

extension Decimal {
    var currencyString: String {
        NSDecimalNumber(decimal: self).formatted(.currency(code: "USD"))
    }
}
