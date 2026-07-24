//
//  PaymentRow.swift
//  dev1
//

import SwiftUI

struct PaymentRow: View {
    let payment: Payment
    let onCollect: () -> Void
    let onRemind: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading) {
                    Text(payment.family?.parentName ?? "Unknown Family")
                        .font(.headline)
                    Text(payment.family?.playerName ?? "")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                statusBadge
            }

            HStack {
                Text("\(payment.amountPaid.currencyString) of \(payment.amountDue.currencyString)")
                    .font(.subheadline)
                Spacer()
                if payment.status != .paid {
                    Button("Remind", action: onRemind)
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    Button("Collect", action: onCollect)
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                }
            }

            if let reminderSentDate = payment.reminderSentDate, payment.status != .paid {
                Text("Last reminded \(reminderSentDate.formatted(.relative(presentation: .named)))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var statusBadge: some View {
        let (text, color): (String, Color) = {
            switch payment.status {
            case .paid: return ("Paid", .green)
            case .partial: return ("Partial", .orange)
            case .unpaid: return ("Unpaid", .red)
            }
        }()
        return StatusPill(text: text, color: color)
    }
}
