//
//  PaymentRow.swift
//  dev1
//

import SwiftUI

struct PaymentRow: View {
    let payment: Payment
    let onCollect: () -> Void
    let onRemind: () -> Void

    private var progress: Double {
        guard payment.amountDue > 0 else { return 0 }
        return Double(truncating: NSDecimalNumber(decimal: payment.amountPaid / payment.amountDue))
    }

    private var parentName: String {
        payment.family?.parentName ?? "Unknown family"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Space.md) {
            HStack(spacing: Theme.Space.md) {
                Avatar(name: parentName, size: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(parentName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.inkPrimary)
                    if let player = payment.family?.playerName, !player.isEmpty {
                        Text(player)
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.inkMuted)
                    }
                }

                Spacer(minLength: Theme.Space.sm)

                StatusBadge(status: payment.status)
            }

            if payment.status != .paid {
                ProgressMeter(fraction: progress, height: 6)
            }

            HStack(alignment: .firstTextBaseline, spacing: Theme.Space.xs) {
                Text(payment.amountPaid.currencyString)
                    .font(Theme.figure(15, weight: .bold))
                    .foregroundStyle(Theme.inkPrimary)
                Text("of \(payment.amountDue.currencyString)")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.inkMuted)

                Spacer()

                if payment.status != .paid {
                    Button(action: onRemind) {
                        Text("Remind")
                            .font(.system(size: 13, weight: .semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Theme.accentMuted, in: Capsule())
                            .foregroundStyle(Theme.accent)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Send reminder to \(parentName)")

                    Button(action: onCollect) {
                        Text("Collect")
                            .font(.system(size: 13, weight: .semibold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(Theme.accent, in: Capsule())
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Collect \(payment.balanceRemaining.currencyString) from \(parentName)")
                }
            }

            if let reminderSentDate = payment.reminderSentDate, payment.status != .paid {
                Label(
                    "Reminded \(reminderSentDate.formatted(.relative(presentation: .named)))",
                    systemImage: "bell.fill"
                )
                .font(.system(size: 11))
                .foregroundStyle(Theme.inkMuted)
            }
        }
        .card()
    }
}
