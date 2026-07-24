//
//  Payment.swift
//  dev1
//

import Foundation
import SwiftData

enum PaymentStatus: String, Codable {
    case unpaid
    case partial
    case paid
}

@Model
final class Payment {
    var id: UUID
    var amountDue: Decimal
    var amountPaid: Decimal
    var statusRaw: String
    var paidDate: Date?
    var reminderSentDate: Date?

    var campaign: FeeCampaign?
    var family: FamilyMember?

    init(campaign: FeeCampaign, family: FamilyMember, amountDue: Decimal) {
        self.id = UUID()
        self.amountDue = amountDue
        self.amountPaid = 0
        self.statusRaw = PaymentStatus.unpaid.rawValue
        self.campaign = campaign
        self.family = family
    }

    var status: PaymentStatus {
        get { PaymentStatus(rawValue: statusRaw) ?? .unpaid }
        set { statusRaw = newValue.rawValue }
    }

    var balanceRemaining: Decimal {
        max(amountDue - amountPaid, 0)
    }

    func recordPayment(amount: Decimal) {
        amountPaid += amount
        paidDate = .now
        status = amountPaid >= amountDue ? .paid : .partial
    }

    func markReminderSent() {
        reminderSentDate = .now
    }
}
