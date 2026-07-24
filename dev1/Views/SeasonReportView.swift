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

    private var reportText: String {
        var lines = ["TeamTreasury Season Financial Report", Date.now.formatted(date: .abbreviated, time: .omitted), ""]

        lines.append("INCOME")
        for campaign in campaigns {
            lines.append("- \(campaign.title): \(campaign.totalCollected.currencyString) of \(campaign.totalExpected.currencyString)")
        }
        lines.append("Total Collected: \(totalCollected.currencyString)")
        lines.append("")

        lines.append("EXPENSES")
        for expense in expenses {
            lines.append("- \(expense.title) (\(expense.category)): \(expense.amount.currencyString)")
        }
        lines.append("Total Expenses: \(totalExpenses.currencyString)")
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
        List {
            Section("Summary") {
                LabeledContent("Collected", value: totalCollected.currencyString)
                LabeledContent("Expected", value: totalExpected.currencyString)
                LabeledContent("Expenses", value: totalExpenses.currencyString)
                LabeledContent("Net Balance", value: netBalance.currencyString)
            }

            Section("Family Balances") {
                ForEach(sortedFamilies) { family in
                    HStack {
                        Text(family.parentName)
                        Spacer()
                        Text(family.totalOwed > 0 ? "\(family.totalOwed.currencyString) due" : "Paid up")
                            .foregroundStyle(family.totalOwed > 0 ? .red : .green)
                    }
                }
            }
        }
        .navigationTitle("Season Report")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: reportText) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
        }
    }
}

#Preview {
    NavigationStack { SeasonReportView() }
        .modelContainer(for: [FamilyMember.self, FeeCampaign.self, Payment.self, Expense.self], inMemory: true)
}
