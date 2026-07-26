//
//  CampaignDetailView.swift
//  dev1
//

import SwiftUI
import SwiftData

struct CampaignDetailView: View {
    @Bindable var campaign: FeeCampaign
    @State private var selectedPayment: Payment?
    @State private var reminderToast: String?

    private var sortedPayments: [Payment] {
        campaign.payments.sorted {
            // Unpaid first — that's the treasurer's working list.
            if ($0.status != .paid) != ($1.status != .paid) {
                return $0.status != .paid
            }
            return ($0.family?.parentName ?? "") < ($1.family?.parentName ?? "")
        }
    }

    private var unpaidPayments: [Payment] {
        campaign.payments.filter { $0.status != .paid }
    }

    private var progress: Double {
        guard campaign.totalExpected > 0 else { return 0 }
        return Double(truncating: NSDecimalNumber(decimal: campaign.totalCollected / campaign.totalExpected))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Space.lg) {
                summaryCard

                if !unpaidPayments.isEmpty {
                    Button {
                        sendReminders(to: unpaidPayments)
                    } label: {
                        Label(
                            "Remind \(unpaidPayments.count) unpaid \(unpaidPayments.count == 1 ? "family" : "families")",
                            systemImage: "bell.badge.fill"
                        )
                        .font(.system(size: 15, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Space.md)
                        .background(Theme.accent, in: RoundedRectangle(cornerRadius: Theme.Radius.control, style: .continuous))
                        .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                }

                if !campaign.notes.isEmpty {
                    VStack(alignment: .leading, spacing: Theme.Space.sm) {
                        Label("Notes", systemImage: "note.text")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.inkSecondary)
                        Text(campaign.notes)
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.inkPrimary)
                    }
                    .card()
                }

                VStack(alignment: .leading, spacing: Theme.Space.md) {
                    Text("Families")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.inkPrimary)
                        .padding(.horizontal, Theme.Space.xs)

                    ForEach(sortedPayments) { payment in
                        PaymentRow(payment: payment) {
                            selectedPayment = payment
                        } onRemind: {
                            sendReminders(to: [payment])
                        }
                    }
                }
            }
            .padding(Theme.Space.lg)
        }
        .background(Theme.plane)
        .navigationTitle(campaign.title)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedPayment) { payment in
            CollectPaymentView(payment: payment)
        }
        .overlay(alignment: .bottom) {
            if let reminderToast {
                Label(reminderToast, systemImage: "checkmark.circle.fill")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, Theme.Space.lg)
                    .padding(.vertical, Theme.Space.md)
                    .background(Theme.inkPrimary.opacity(0.92), in: Capsule())
                    .padding(.bottom, Theme.Space.xxl)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: Theme.Space.md) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Collected")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Theme.inkSecondary)
                    Text(campaign.totalCollected.currencyString)
                        .font(Theme.figure(32, weight: .bold))
                        .foregroundStyle(Theme.inkPrimary)
                    Text("of \(campaign.totalExpected.currencyString) expected")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.inkMuted)
                }
                Spacer()
                MetaBadge(
                    text: campaign.dueDate.formatted(date: .abbreviated, time: .omitted),
                    systemImage: "calendar",
                    tint: campaign.dueDate < .now && campaign.unpaidCount > 0
                        ? Theme.statusCritical
                        : Theme.inkSecondary
                )
            }

            ProgressMeter(fraction: progress)
        }
        .card()
    }

    private func sendReminders(to payments: [Payment]) {
        payments.forEach { $0.markReminderSent() }
        withAnimation {
            reminderToast = "Reminder sent to \(payments.count) \(payments.count == 1 ? "family" : "families")"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { reminderToast = nil }
        }
    }
}
