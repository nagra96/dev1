//
//  FeeCampaign.swift
//  dev1
//

import Foundation
import SwiftData

@Model
final class FeeCampaign {
    var id: UUID
    var title: String
    var amount: Decimal
    var dueDate: Date
    var notes: String
    var createdDate: Date

    @Relationship(deleteRule: .cascade, inverse: \Payment.campaign)
    var payments: [Payment] = []

    init(title: String, amount: Decimal, dueDate: Date, notes: String = "") {
        self.id = UUID()
        self.title = title
        self.amount = amount
        self.dueDate = dueDate
        self.notes = notes
        self.createdDate = .now
    }

    var totalCollected: Decimal {
        payments.reduce(Decimal(0)) { $0 + $1.amountPaid }
    }

    var totalExpected: Decimal {
        payments.reduce(Decimal(0)) { $0 + $1.amountDue }
    }

    var unpaidCount: Int {
        payments.filter { $0.status != .paid }.count
    }
}
