//
//  CampaignRow.swift
//  dev1
//

import SwiftUI

struct CampaignRow: View {
    let campaign: FeeCampaign

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(campaign.title)
                .font(.headline)
            Text("Due \(campaign.dueDate.formatted(date: .abbreviated, time: .omitted))")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack {
                Text("\(campaign.totalCollected.currencyString) of \(campaign.totalExpected.currencyString)")
                    .font(.subheadline)
                Spacer()
                StatusPill(
                    text: campaign.unpaidCount > 0 ? "\(campaign.unpaidCount) unpaid" : "Fully paid",
                    color: campaign.unpaidCount > 0 ? .orange : .green
                )
            }
        }
        .padding(.vertical, 4)
    }
}

struct StatusPill: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}
