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
        Group {
            if campaigns.isEmpty {
                EmptyStateView(
                    icon: "dollarsign.circle.fill",
                    title: "No fee campaigns",
                    message: "Create a campaign like \u{201C}Uniform Fee \u{2014} $150\u{201D} to start collecting from your roster.",
                    actionTitle: "New Campaign"
                ) {
                    isPresentingNewCampaign = true
                }
            } else {
                List {
                    ForEach(campaigns) { campaign in
                        ZStack {
                            // A zero-opacity NavigationLink keeps the row's tap
                            // target and push behavior without painting the
                            // system disclosure chrome over the card.
                            NavigationLink(value: campaign) { EmptyView() }.opacity(0)
                            CampaignRow(campaign: campaign)
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: Theme.Space.sm, leading: Theme.Space.lg,
                                                  bottom: Theme.Space.sm, trailing: Theme.Space.lg))
                    }
                    .onDelete { pendingDeleteOffsets = $0 }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .background(Theme.plane)
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
