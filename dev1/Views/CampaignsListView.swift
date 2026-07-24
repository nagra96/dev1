//
//  CampaignsListView.swift
//  dev1
//

import SwiftUI
import SwiftData

struct CampaignsListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \FeeCampaign.dueDate) private var campaigns: [FeeCampaign]
    @State private var isPresentingNewCampaign = false

    var body: some View {
        List {
            if campaigns.isEmpty {
                ContentUnavailableView(
                    "No Fee Campaigns",
                    systemImage: "dollarsign.circle",
                    description: Text("Create a campaign like \u{201C}Uniform Fee \u{2014} $150\u{201D} to start collecting.")
                )
            } else {
                ForEach(campaigns) { campaign in
                    NavigationLink(value: campaign) {
                        CampaignRow(campaign: campaign)
                    }
                }
                .onDelete(perform: deleteCampaigns)
            }
        }
        .navigationDestination(for: FeeCampaign.self) { campaign in
            CampaignDetailView(campaign: campaign)
        }
        .navigationTitle("Fee Campaigns")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isPresentingNewCampaign = true
                } label: {
                    Label("New Campaign", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isPresentingNewCampaign) {
            NewCampaignView()
        }
    }

    private func deleteCampaigns(at offsets: IndexSet) {
        for index in offsets {
            context.delete(campaigns[index])
        }
    }
}

#Preview {
    NavigationStack { CampaignsListView() }
        .modelContainer(for: [FamilyMember.self, FeeCampaign.self, Payment.self, Expense.self], inMemory: true)
}
