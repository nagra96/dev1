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

    private var outstanding: Decimal {
        max(totalExpected - totalCollected, 0)
    }

    private var netBalance: Decimal {
        totalCollected - totalExpenses
    }

    private var outstandingFamiliesCount: Int {
        Set(
            campaigns.flatMap { campaign in
                campaign.payments.filter { $0.status != .paid }.compactMap { $0.family?.id }
            }
        ).count
    }

    private var collectionProgress: Double {
        guard totalExpected > 0 else { return 0 }
        return Double(truncating: NSDecimalNumber(decimal: totalCollected / totalExpected))
    }

    private var sortedCampaigns: [FeeCampaign] {
        campaigns.sorted { $0.dueDate < $1.dueDate }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Space.lg) {
                heroCard

                // KPI row: each of these is one current value, so it's a tile,
                // not a one-bar chart.
                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: Theme.Space.md),
                              GridItem(.flexible(), spacing: Theme.Space.md)],
                    spacing: Theme.Space.md
                ) {
                    StatTile(
                        label: "Collected",
                        value: totalCollected.currencyString,
                        systemImage: "arrow.down.circle.fill",
                        tint: Theme.statusGood
                    )
                    StatTile(
                        label: "Still owed",
                        value: outstanding.currencyString,
                        systemImage: "clock.fill",
                        tint: Theme.statusWarning
                    )
                    StatTile(
                        label: "Expenses",
                        value: totalExpenses.currencyString,
                        systemImage: "arrow.up.circle.fill",
                        tint: Theme.statusCritical
                    )
                    StatTile(
                        label: "Families",
                        value: "\(families.count)",
                        systemImage: "person.2.fill",
                        tint: Theme.accent,
                        caption: outstandingFamiliesCount == 0
                            ? "All paid up"
                            : "\(outstandingFamiliesCount) with a balance"
                    )
                }

                progressCard
                campaignsSection
            }
            .padding(Theme.Space.lg)
        }
        .background(Theme.plane)
        .navigationDestination(for: FeeCampaign.self) { campaign in
            CampaignDetailView(campaign: campaign)
        }
        .navigationTitle("TeamTreasury")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SeasonReportView()
                } label: {
                    Label("Season Report", systemImage: "doc.text")
                }
            }
        }
    }

    // MARK: - Hero

    /// The one number the dashboard leads with. Exactly one hero per view.
    private var heroCard: some View {
        VStack(alignment: .leading, spacing: Theme.Space.sm) {
            Text("Net balance")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.85))

            Text(netBalance.currencyString)
                .font(Theme.figure(48, weight: .bold))
                .foregroundStyle(.white)
                .minimumScaleFactor(0.5)
                .lineLimit(1)

            Text("\(totalCollected.currencyString) collected \u{2212} \(totalExpenses.currencyString) spent")
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Net balance")
        .accessibilityValue(netBalance.currencyString)
    }

    // MARK: - Progress

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: Theme.Space.md) {
            HStack {
                Text("Collection progress")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.inkPrimary)
                Spacer()
                Text("\(Int((collectionProgress * 100).rounded()))%")
                    .font(Theme.figure(15, weight: .bold))
                    .foregroundStyle(Theme.accent)
            }

            ProgressMeter(fraction: collectionProgress)

            Text(
                families.isEmpty
                    ? "Add families to start tracking balances."
                    : "\(outstandingFamiliesCount) of \(families.count) families still owe money"
            )
            .font(.system(size: 12))
            .foregroundStyle(Theme.inkMuted)
        }
        .card()
    }

    // MARK: - Campaigns

    private var campaignsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Space.md) {
            Text("Fee campaigns")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.inkPrimary)
                .padding(.horizontal, Theme.Space.xs)

            if sortedCampaigns.isEmpty {
                VStack(spacing: Theme.Space.sm) {
                    Image(systemName: "dollarsign.circle")
                        .font(.system(size: 28))
                        .foregroundStyle(Theme.accent)
                    Text("No campaigns yet")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.inkPrimary)
                    Text("Create one from the Fee Campaigns tab to start collecting.")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.inkMuted)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Space.lg)
                .card()
            } else {
                ForEach(sortedCampaigns) { campaign in
                    NavigationLink(value: campaign) {
                        CampaignRow(campaign: campaign)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    NavigationStack { DashboardView() }
        .modelContainer(for: [TeamProfile.self, FamilyMember.self, FeeCampaign.self, Payment.self, Expense.self], inMemory: true)
}
