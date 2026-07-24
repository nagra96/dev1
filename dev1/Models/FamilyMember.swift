//
//  FamilyMember.swift
//  dev1
//

import Foundation
import SwiftData

@Model
final class FamilyMember {
    var id: UUID
    var parentName: String
    var playerName: String
    var email: String
    var phone: String

    @Relationship(deleteRule: .cascade, inverse: \Payment.family)
    var payments: [Payment] = []

    init(parentName: String, playerName: String, email: String = "", phone: String = "") {
        self.id = UUID()
        self.parentName = parentName
        self.playerName = playerName
        self.email = email
        self.phone = phone
    }

    var totalOwed: Decimal {
        payments.reduce(Decimal(0)) { $0 + $1.balanceRemaining }
    }

    var totalPaid: Decimal {
        payments.reduce(Decimal(0)) { $0 + $1.amountPaid }
    }
}
