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

    private static let logger = Logger(subsystem: "com.teamtreasury.dev1", category: "FamiliesListView")

    var body: some View {
        List {
            if families.isEmpty {
                ContentUnavailableView(
                    "No Families Yet",
                    systemImage: "person.2",
                    description: Text("Add families to start tracking balances.")
                )
            } else {
                ForEach(families) { family in
                    NavigationLink(value: family) {
                        FamilyRow(family: family)
                    }
                }
                .onDelete { pendingDeleteOffsets = $0 }
            }
        }
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
        for index in offsets {
            context.delete(families[index])
        }
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
        HStack {
            VStack(alignment: .leading) {
                Text(family.parentName).font(.headline)
                Text(family.playerName).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            if family.totalOwed > 0 {
                Text("\(family.totalOwed.currencyString) due")
                    .font(.subheadline)
                    .foregroundStyle(.red)
            } else {
                Text("Paid up")
                    .font(.subheadline)
                    .foregroundStyle(.green)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(family.parentName), \(family.playerName)")
        .accessibilityValue(family.totalOwed > 0 ? "\(family.totalOwed.currencyString) due" : "Paid up")
    }
}

#Preview {
    NavigationStack { FamiliesListView() }
        .modelContainer(for: [FamilyMember.self, FeeCampaign.self, Payment.self, Expense.self], inMemory: true)
}
