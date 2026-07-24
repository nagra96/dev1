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
        campaign.payments.sorted { ($0.family?.parentName ?? "") < ($1.family?.parentName ?? "") }
    }

    private var unpaidPayments: [Payment] {
        campaign.payments.filter { $0.status != .paid }
    }

    var body: some View {
        List {
            Section("Progress") {
                HStack {
                    Text("Collected")
                    Spacer()
                    Text(campaign.totalCollected.currencyString)
                        .fontWeight(.semibold)
                }
                HStack {
                    Text("Expected")
                    Spacer()
                    Text(campaign.totalExpected.currencyString)
                }
                if !unpaidPayments.isEmpty {
                    Button {
                        sendReminders(to: unpaidPayments)
                    } label: {
                        Label("Remind \(unpaidPayments.count) Unpaid \(unpaidPayments.count == 1 ? "Family" : "Families")", systemImage: "bell.badge")
                    }
                }
            }

            Section("Families") {
                ForEach(sortedPayments) { payment in
                    PaymentRow(payment: payment) {
                        selectedPayment = payment
                    } onRemind: {
                        sendReminders(to: [payment])
                    }
                }
            }

            if !campaign.notes.isEmpty {
                Section("Notes") {
                    Text(campaign.notes)
                }
            }
        }
        .navigationTitle(campaign.title)
        .sheet(item: $selectedPayment) { payment in
            CollectPaymentView(payment: payment)
        }
        .overlay(alignment: .bottom) {
            if let reminderToast {
                Text(reminderToast)
                    .font(.footnote)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.thinMaterial, in: Capsule())
                    .padding(.bottom, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
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
