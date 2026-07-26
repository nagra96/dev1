//
//  CampaignRow.swift
//  dev1
//

import SwiftUI

struct CampaignRow: View {
    let campaign: FeeCampaign

    private var progress: Double {
        let expected = campaign.totalExpected
        guard expected > 0 else { return 0 }
        return Double(truncating: NSDecimalNumber(decimal: campaign.totalCollected / expected))
    }

    private var isOverdue: Bool {
        campaign.dueDate < .now && campaign.unpaidCount > 0
    }

    private var dueText: String {
        let formatted = campaign.dueDate.formatted(date: .abbreviated, time: .omitted)
        return isOverdue ? "Overdue \(formatted)" : "Due \(formatted)"
    }

    /// Loose keyword match so a campaign gets a glyph that fits what it's for.
    /// Decorative only — the title is always shown beside it.
    private var icon: String {
        let title = campaign.title.lowercased()
        if title.contains("uniform") || title.contains("jersey") { return "tshirt.fill" }
        if title.contains("tournament") || title.contains("championship") { return "trophy.fill" }
        if title.contains("travel") || title.contains("hotel") { return "bus.fill" }
        if title.contains("registration") || title.contains("league") { return "list.clipboard.fill" }
        if title.contains("equipment") || title.contains("gear") { return "bag.fill" }
        return "dollarsign.circle.fill"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Space.md) {
            HStack(alignment: .top, spacing: Theme.Space.md) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.accent)
                    .frame(width: 36, height: 36)
                    .background(Theme.accentMuted, in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(campaign.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.inkPrimary)
                    Text(dueText)
                        .font(.system(size: 12))
                        .foregroundStyle(isOverdue ? Theme.statusCritical : Theme.inkMuted)
                }

                Spacer(minLength: Theme.Space.sm)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.inkMuted)
                    .padding(.top, 4)
            }

            ProgressMeter(fraction: progress, height: 8)

            HStack(alignment: .firstTextBaseline, spacing: Theme.Space.xs) {
                Text(campaign.totalCollected.currencyString)
                    .font(Theme.figure(15, weight: .bold))
                    .foregroundStyle(Theme.inkPrimary)
                Text("of \(campaign.totalExpected.currencyString)")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.inkMuted)

                Spacer()

                if campaign.unpaidCount > 0 {
                    MetaBadge(
                        text: "\(campaign.unpaidCount) unpaid",
                        systemImage: "person.fill.questionmark",
                        tint: Theme.statusWarning
                    )
                } else {
                    MetaBadge(
                        text: "All paid",
                        systemImage: "checkmark.circle.fill",
                        tint: Theme.statusGood
                    )
                }
            }
        }
        .card()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(campaign.title), \(dueText)")
        .accessibilityValue(
            "\(campaign.totalCollected.currencyString) of \(campaign.totalExpected.currencyString) collected, \(campaign.unpaidCount) unpaid"
        )
    }
}
