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
        ScrollView {
            VStack(spacing: Theme.Space.lg) {
                headerCard
                balanceCard

                VStack(alignment: .leading, spacing: Theme.Space.md) {
                    Text("Fee history")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.inkPrimary)
                        .padding(.horizontal, Theme.Space.xs)

                    if sortedPayments.isEmpty {
                        Text("No fees assigned yet. Create a campaign to bill this family.")
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.inkMuted)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .card()
                    } else {
                        ForEach(sortedPayments) { payment in
                            VStack(alignment: .leading, spacing: Theme.Space.xs) {
                                Text(payment.campaign?.title ?? "Fee")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(Theme.inkSecondary)
                                    .padding(.horizontal, Theme.Space.xs)
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
            .padding(Theme.Space.lg)
        }
        .background(Theme.plane)
        .navigationTitle(family.parentName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedPayment) { payment in
            CollectPaymentView(payment: payment)
        }
    }

    private var headerCard: some View {
        HStack(spacing: Theme.Space.lg) {
            Avatar(name: family.parentName, size: 60)

            VStack(alignment: .leading, spacing: 3) {
                Text(family.parentName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Theme.inkPrimary)
                if !family.playerName.isEmpty {
                    Label(family.playerName, systemImage: "figure.run")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.inkSecondary)
                }
                if !family.email.isEmpty {
                    Text(family.email)
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.inkMuted)
                }
                if !family.phone.isEmpty {
                    Text(family.phone)
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.inkMuted)
                }
            }

            Spacer(minLength: 0)
        }
        .card()
    }

    private var balanceCard: some View {
        HStack(spacing: Theme.Space.md) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Paid")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.inkSecondary)
                Text(family.totalPaid.currencyString)
                    .font(Theme.figure(22, weight: .bold))
                    .foregroundStyle(Theme.statusGood)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider().frame(height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text("Owed")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.inkSecondary)
                Text(family.totalOwed.currencyString)
                    .font(Theme.figure(22, weight: .bold))
                    .foregroundStyle(family.totalOwed > 0 ? Theme.statusCritical : Theme.inkPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .card()
    }
}
