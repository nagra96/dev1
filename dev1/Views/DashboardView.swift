//
//  DashboardView.swift
//  dev1
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query private var campaigns: [FeeCampaign]
    @Query private var expenses: [Expense]
    @Query private var families: [FamilyMember]

    private var totalCollected: Decimal {
        campaigns.reduce(Decimal(0)) { $0 + $1.totalCollected }
    }

    private var totalExpected: Decimal {
        campaigns.reduce(Decimal(0)) { $0 + $1.totalExpected }
    }

    private var totalExpenses: Decimal {
        expenses.reduce(Decimal(0)) { $0 + $1.amount }
    }

    private var netBalance: Decimal {
        totalCollected - totalExpenses
    }

    private var outstandingFamiliesCount: Int {
        Set(campaigns.flatMap { $0.payments.filter { $0.status != .paid }.compactMap { $0.family?.id } }).count
    }

    private var collectionProgress: Double {
        guard totalExpected > 0 else { return 0 }
        return Double(truncating: NSDecimalNumber(decimal: totalCollected / totalExpected))
    }

    var body: some View {
        List {
            Section("Season Snapshot") {
                StatRow(label: "Collected", value: totalCollected.currencyString, tint: .green)
                StatRow(label: "Expected", value: totalExpected.currencyString, tint: .blue)
                StatRow(label: "Expenses", value: totalExpenses.currencyString, tint: .orange)
                StatRow(label: "Net Balance", value: netBalance.currencyString, tint: netBalance >= 0 ? .green : .red)
            }

            Section("Collection Progress") {
                ProgressView(value: collectionProgress, total: 1)
                Text("\(outstandingFamiliesCount) of \(families.count) families have an outstanding balance")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Active Fee Campaigns") {
                if campaigns.isEmpty {
                    Text("No campaigns yet. Create one from the Fee Campaigns tab.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(campaigns.sorted(by: { $0.dueDate < $1.dueDate })) { campaign in
                        NavigationLink(value: campaign) {
                            CampaignRow(campaign: campaign)
                        }
                    }
                }
            }
        }
        .navigationDestination(for: FeeCampaign.self) { campaign in
            CampaignDetailView(campaign: campaign)
        }
        .navigationTitle("TeamTreasury")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SeasonReportView()
                } label: {
                    Label("Season Report", systemImage: "square.and.arrow.up")
                }
            }
        }
    }
}

private struct StatRow: View {
    let label: String
    let value: String
    let tint: Color

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(tint)
        }
    }
}

#Preview {
    NavigationStack { DashboardView() }
        .modelContainer(for: [FamilyMember.self, FeeCampaign.self, Payment.self, Expense.self], inMemory: true)
}
