//
//  FamilyDetailView.swift
//  dev1
//

import SwiftUI

struct FamilyDetailView: View {
    @Bindable var family: FamilyMember
    @State private var selectedPayment: Payment?

    private var sortedPayments: [Payment] {
        family.payments.sorted { ($0.campaign?.dueDate ?? .now) < ($1.campaign?.dueDate ?? .now) }
    }

    var body: some View {
        List {
            Section("Contact") {
                if !family.email.isEmpty {
                    LabeledContent("Email", value: family.email)
                }
                if !family.phone.isEmpty {
                    LabeledContent("Phone", value: family.phone)
                }
                LabeledContent("Player", value: family.playerName)
            }

            Section("Balance") {
                LabeledContent("Total Paid", value: family.totalPaid.currencyString)
                LabeledContent("Total Owed", value: family.totalOwed.currencyString)
            }

            Section("Fee History") {
                if sortedPayments.isEmpty {
                    Text("No fees assigned yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(sortedPayments) { payment in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(payment.campaign?.title ?? "Fee")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            PaymentRow(payment: payment) {
                                selectedPayment = payment
                            } onRemind: {
                                payment.markReminderSent()
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(family.parentName)
        .sheet(item: $selectedPayment) { payment in
            CollectPaymentView(payment: payment)
        }
    }
}
