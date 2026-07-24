//
//  Expense.swift
//  dev1
//

import Foundation
import SwiftData

@Model
final class Expense {
    var id: UUID
    var title: String
    var category: String
    var amount: Decimal
    var date: Date
    var note: String
    @Attribute(.externalStorage) var receiptImageData: Data?

    init(title: String, category: String, amount: Decimal, date: Date = .now, note: String = "", receiptImageData: Data? = nil) {
        self.id = UUID()
        self.title = title
        self.category = category
        self.amount = amount
        self.date = date
        self.note = note
        self.receiptImageData = receiptImageData
    }
}
