//
//  CampaignsListView.swift
//  dev1
//

import SwiftUI
import SwiftData
import os

struct CampaignsListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \FeeCampaign.dueDate) private var campaigns: [FeeCampaign]
    @State private var isPresentingNewCampaign = false
    @State private var pendingDeleteOffsets: IndexSet?

    private static let logger = Logger(subsystem: "com.teamtreasury.dev1", category: "CampaignsListView")

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
                .onDelete { pendingDeleteOffsets = $0 }
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
        .confirmationDialog(
            "Delete Campaign?",
            isPresented: .constant(pendingDeleteOffsets != nil),
            titleVisibility: .visible
        ) {
            Button("Delete Campaign and Payment Records", role: .destructive) {
                if let offsets = pendingDeleteOffsets {
                    deleteCampaigns(at: offsets)
                }
                pendingDeleteOffsets = nil
            }
            Button("Cancel", role: .cancel) {
                pendingDeleteOffsets = nil
            }
        } message: {
            Text("This permanently deletes the campaign along with every family\u{2019}s balance and payment history for it.")
        }
    }

    private func deleteCampaigns(at offsets: IndexSet) {
        for index in offsets {
            context.delete(campaigns[index])
        }
        do {
            try context.save()
        } catch {
            context.rollback()
            Self.logger.error("Failed to delete campaign: \(error.localizedDescription)")
        }
    }
}

#Preview {
    NavigationStack { CampaignsListView() }
        .modelContainer(for: [FamilyMember.self, FeeCampaign.self, Payment.self, Expense.self], inMemory: true)
}
