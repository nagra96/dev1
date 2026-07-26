//
//  Decimal+Currency.swift
//  dev1
//

import Foundation

extension Decimal {
    var currencyString: String {
        formatted(.currency(code: "USD"))
    }
}
