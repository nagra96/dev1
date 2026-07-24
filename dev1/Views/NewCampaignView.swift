//
//  NewCampaignView.swift
//  dev1
//

import SwiftUI
import SwiftData

struct NewCampaignView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var families: [FamilyMember]

    @State private var title = ""
    @State private var amountText = ""
    @State private var dueDate = Calendar.current.date(byAdding: .day, value: 14, to: .now) ?? .now
    @State private var notes = ""

    private var parsedAmount: Decimal? {
        Decimal(string: amountText)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Campaign Details") {
                    TextField("Title (e.g. Uniform Fee)", text: $title)
                    TextField("Amount per family", text: $amountText)
                        .keyboardType(.decimalPad)
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                    TextField("Notes", text: $notes, axis: .vertical)
                }

                Section {
                    Text("This creates a $\(amountText.isEmpty ? "0" : amountText) balance for each of the \(families.count) families on your roster, with automatic reminders for anyone who hasn\u{2019}t paid.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("New Fee Campaign")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { createCampaign() }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || parsedAmount == nil)
                }
            }
        }
    }

    private func createCampaign() {
        guard let amount = parsedAmount else { return }
        let campaign = FeeCampaign(title: title, amount: amount, dueDate: dueDate, notes: notes)
        context.insert(campaign)

        for family in families {
            context.insert(Payment(campaign: campaign, family: family, amountDue: amount))
        }

        try? context.save()
        dismiss()
    }
}

#Preview {
    NewCampaignView()
        .modelContainer(for: [FamilyMember.self, FeeCampaign.self, Payment.self, Expense.self], inMemory: true)
}
