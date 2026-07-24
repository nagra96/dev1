//
//  FamiliesListView.swift
//  dev1
//

import SwiftUI
import SwiftData

struct FamiliesListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \FamilyMember.parentName) private var families: [FamilyMember]
    @State private var isPresentingNewFamily = false

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
                .onDelete(perform: deleteFamilies)
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
    }

    private func deleteFamilies(at offsets: IndexSet) {
        for index in offsets {
            context.delete(families[index])
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
    }
}

#Preview {
    NavigationStack { FamiliesListView() }
        .modelContainer(for: [FamilyMember.self, FeeCampaign.self, Payment.self, Expense.self], inMemory: true)
}
