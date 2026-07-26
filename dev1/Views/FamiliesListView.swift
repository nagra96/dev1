//
//  FamiliesListView.swift
//  dev1
//

import SwiftUI
import SwiftData
import os

struct FamiliesListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \FamilyMember.parentName) private var families: [FamilyMember]
    @State private var isPresentingNewFamily = false
    @State private var pendingDeleteOffsets: IndexSet?
    @State private var searchText = ""

    private static let logger = Logger(subsystem: "com.teamtreasury.dev1", category: "FamiliesListView")

    private var totalOutstanding: Decimal {
        families.reduce(Decimal(0)) { $0 + $1.totalOwed }
    }

    private var filteredFamilies: [FamilyMember] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return families }
        return families.filter {
            $0.parentName.localizedCaseInsensitiveContains(query)
                || $0.playerName.localizedCaseInsensitiveContains(query)
                || $0.email.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        Group {
            if families.isEmpty {
                EmptyStateView(
                    icon: "person.2.fill",
                    title: "No families yet",
                    message: "Add the families on your roster and TeamTreasury will track every balance for you.",
                    actionTitle: "Add Family"
                ) {
                    isPresentingNewFamily = true
                }
            } else {
                List {
                    Section {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Outstanding across roster")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(Theme.inkSecondary)
                                Text(totalOutstanding.currencyString)
                                    .font(Theme.figure(26, weight: .bold))
                                    .foregroundStyle(totalOutstanding > 0 ? Theme.inkPrimary : Theme.statusGood)
                            }
                            Spacer()
                            Image(systemName: totalOutstanding > 0 ? "hourglass" : "checkmark.seal.fill")
                                .font(.system(size: 26))
                                .foregroundStyle(totalOutstanding > 0 ? Theme.statusWarning : Theme.statusGood)
                        }
                        .card()
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: Theme.Space.md, leading: Theme.Space.lg,
                                                  bottom: Theme.Space.sm, trailing: Theme.Space.lg))
                    }

                    ForEach(filteredFamilies) { family in
                        ZStack {
                            NavigationLink(value: family) { EmptyView() }.opacity(0)
                            FamilyRow(family: family)
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
                .searchable(text: $searchText, prompt: "Search parent, player, or email")
                .overlay {
                    if filteredFamilies.isEmpty && !searchText.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                    }
                }
            }
        }
        .background(Theme.plane)
        .navigationDestination(for: FamilyMember.self) { family in
            FamilyDetailView(family: family)
        }
        .navigationTitle("Families")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isPresentingNewFamily = true
                } label: {
                    Label("Add Family", systemImage: "person.badge.plus")
                }
            }
        }
        .sheet(isPresented: $isPresentingNewFamily) {
            NewFamilyView()
        }
        .confirmationDialog(
            "Remove Family?",
            isPresented: .constant(pendingDeleteOffsets != nil),
            titleVisibility: .visible
        ) {
            Button("Remove Family and Fee History", role: .destructive) {
                if let offsets = pendingDeleteOffsets {
                    deleteFamilies(at: offsets)
                }
                pendingDeleteOffsets = nil
            }
            Button("Cancel", role: .cancel) {
                pendingDeleteOffsets = nil
            }
        } message: {
            Text("This permanently deletes the family and every fee balance and payment record tied to them.")
        }
    }

    private func deleteFamilies(at offsets: IndexSet) {
        // Offsets index into the filtered array the user is actually looking
        // at — resolving them against `families` would delete the wrong row
        // whenever a search is active.
        let targets = offsets.map { filteredFamilies[$0] }
        targets.forEach { context.delete($0) }
        do {
            try context.save()
        } catch {
            context.rollback()
            Self.logger.error("Failed to delete family: \(error.localizedDescription)")
        }
    }
}

private struct FamilyRow: View {
    let family: FamilyMember

    var body: some View {
        HStack(spacing: Theme.Space.md) {
            Avatar(name: family.parentName, size: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(family.parentName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.inkPrimary)
                if !family.playerName.isEmpty {
                    Text(family.playerName)
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.inkMuted)
                }
            }

            Spacer(minLength: Theme.Space.sm)

            VStack(alignment: .trailing, spacing: 4) {
                if family.totalOwed > 0 {
                    Text(family.totalOwed.currencyString)
                        .font(Theme.figure(16, weight: .bold))
                        .foregroundStyle(Theme.inkPrimary)
                    MetaBadge(text: "Owes", systemImage: "exclamationmark.circle.fill", tint: Theme.statusCritical)
                } else {
                    MetaBadge(text: "Paid up", systemImage: "checkmark.circle.fill", tint: Theme.statusGood)
                }
            }
        }
        .card()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(family.parentName), \(family.playerName)")
        .accessibilityValue(family.totalOwed > 0 ? "\(family.totalOwed.currencyString) due" : "Paid up")
    }
}

#Preview {
    NavigationStack { FamiliesListView() }
        .modelContainer(for: [TeamProfile.self, FamilyMember.self, FeeCampaign.self, Payment.self, Expense.self], inMemory: true)
}
