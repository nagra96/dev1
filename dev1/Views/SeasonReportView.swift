//
//  SeasonReportView.swift
//  dev1
//

import SwiftUI
import SwiftData

struct SeasonReportView: View {
    @Query private var campaigns: [FeeCampaign]
    @Query private var expenses: [Expense]
    @Query private var families: [FamilyMember]

    private var totalCollected: Decimal { campaigns.reduce(Decimal(0)) { $0 + $1.totalCollected } }
    private var totalExpected: Decimal { campaigns.reduce(Decimal(0)) { $0 + $1.totalExpected } }
    private var totalExpenses: Decimal { expenses.reduce(Decimal(0)) { $0 + $1.amount } }
    private var netBalance: Decimal { totalCollected - totalExpenses }

    private var sortedFamilies: [FamilyMember] {
        families.sorted { $0.parentName < $1.parentName }
    }

    private var expensesByCategory: [CategoryTotal] {
        Dictionary(grouping: expenses, by: \.category)
            .map { CategoryTotal(category: $0.key, total: $0.value.reduce(Decimal(0)) { $0 + $1.amount }) }
            .sorted { $0.total > $1.total }
    }

    /// Plain-text twin of the report. Every number on screen is also here, so
    /// the data is never gated behind the visual layer.
    private var reportText: String {
        var lines = [
            "TeamTreasury \u{2014} Season Financial Report",
            Date.now.formatted(date: .abbreviated, time: .omitted),
            ""
        ]

        lines.append("INCOME")
        for campaign in campaigns.sorted(by: { $0.dueDate < $1.dueDate }) {
            lines.append("- \(campaign.title): \(campaign.totalCollected.currencyString) of \(campaign.totalExpected.currencyString)")
        }
        lines.append("Total collected: \(totalCollected.currencyString)")
        lines.append("")

        lines.append("EXPENSES")
        for expense in expenses.sorted(by: { $0.date < $1.date }) {
            lines.append("- \(expense.title) (\(expense.category)): \(expense.amount.currencyString)")
        }
        lines.append("Total expenses: \(totalExpenses.currencyString)")
        lines.append("")

        lines.append("NET BALANCE: \(netBalance.currencyString)")
        lines.append("")

        lines.append("FAMILY BALANCES")
        for family in sortedFamilies {
            lines.append("- \(family.parentName): \(family.totalOwed > 0 ? "\(family.totalOwed.currencyString) due" : "Paid up")")
        }

        return lines.joined(separator: "\n")
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Space.lg) {
                heroCard

                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: Theme.Space.md),
                              GridItem(.flexible(), spacing: Theme.Space.md)],
                    spacing: Theme.Space.md
                ) {
                    StatTile(label: "Collected", value: totalCollected.currencyString, tint: Theme.statusGood)
                    StatTile(label: "Expected", value: totalExpected.currencyString, tint: Theme.accent)
                    StatTile(label: "Expenses", value: totalExpenses.currencyString, tint: Theme.statusCritical)
                    StatTile(label: "Families", value: "\(families.count)", tint: Theme.accent)
                }

                ExpenseBreakdownChart(totals: expensesByCategory)

                familyBalancesCard
            }
            .padding(Theme.Space.lg)
        }
        .background(Theme.plane)
        .navigationTitle("Season Report")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: reportText) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: Theme.Space.sm) {
            Text("Net balance")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.85))
            Text(netBalance.currencyString)
                .font(Theme.figure(44, weight: .bold))
                .foregroundStyle(.white)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            Text("As of \(Date.now.formatted(date: .abbreviated, time: .omitted))")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Space.xl)
        .background(
            LinearGradient(
                colors: [Theme.accent, Theme.accent.opacity(0.78)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        .shadow(color: Theme.accent.opacity(0.28), radius: 14, x: 0, y: 6)
    }

    private var familyBalancesCard: some View {
        VStack(alignment: .leading, spacing: Theme.Space.md) {
            Text("Family balances")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.inkPrimary)

            if sortedFamilies.isEmpty {
                Text("No families on the roster yet.")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.inkMuted)
            } else {
                ForEach(Array(sortedFamilies.enumerated()), id: \.element.id) { index, family in
                    if index > 0 { Divider() }
                    HStack(spacing: Theme.Space.md) {
                        Avatar(name: family.parentName, size: 32)
                        Text(family.parentName)
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.inkPrimary)
                        Spacer()
                        if family.totalOwed > 0 {
                            Text(family.totalOwed.currencyString)
                                // Tabular here: this is a column of numbers
                                // that must align vertically.
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .monospacedDigit()
                                .foregroundStyle(Theme.statusCritical)
                        } else {
                            MetaBadge(text: "Paid up", systemImage: "checkmark.circle.fill", tint: Theme.statusGood)
                        }
                    }
                }
            }
        }
        .card()
    }
}

#Preview {
    NavigationStack { SeasonReportView() }
        .modelContainer(for: [FamilyMember.self, FeeCampaign.self, Payment.self, Expense.self], inMemory: true)
}
