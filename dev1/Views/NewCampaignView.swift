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
    @State private var validationMessage: String?
    @State private var saveErrorMessage: String?

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var parsedAmount: Decimal? {
        try? CurrencyInput.parse(amountText).get()
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Campaign Details") {
                    TextField("Title (e.g. Uniform Fee)", text: $title)
                        .accessibilityIdentifier("campaignTitleField")
                    TextField("Amount per family", text: $amountText)
                        .keyboardType(.decimalPad)
                        .accessibilityIdentifier("campaignAmountField")
                    if let validationMessage {
                        Text(validationMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                    TextField("Notes", text: $notes, axis: .vertical)
                }

                Section {
                    if families.isEmpty {
                        Label("Add families to your roster first so this campaign has someone to bill.", systemImage: "exclamationmark.triangle")
                            .font(.footnote)
                            .foregroundStyle(.orange)
                    } else {
                        Text("This creates a \(parsedAmount?.currencyString ?? "$0") balance for each of the \(families.count) families on your roster, with automatic reminders for anyone who hasn\u{2019}t paid.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("New Fee Campaign")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { createCampaign() }
                        .disabled(trimmedTitle.isEmpty || families.isEmpty)
                }
            }
            .alert("Couldn\u{2019}t Save Campaign", isPresented: .constant(saveErrorMessage != nil), presenting: saveErrorMessage) { _ in
                Button("OK") { saveErrorMessage = nil }
            } message: { message in
                Text(message)
            }
        }
    }

    private func createCampaign() {
        switch CurrencyInput.parse(amountText) {
        case .failure(let error):
            validationMessage = error.errorDescription
            return
        case .success(let amount):
            validationMessage = nil

            let campaign = FeeCampaign(title: trimmedTitle, amount: amount, dueDate: dueDate, notes: notes.trimmingCharacters(in: .whitespacesAndNewlines))
            context.insert(campaign)

            for family in families {
                context.insert(Payment(campaign: campaign, family: family, amountDue: amount))
            }

            do {
                try context.save()
                dismiss()
            } catch {
                context.rollback()
                saveErrorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    NewCampaignView()
        .modelContainer(for: [TeamProfile.self, FamilyMember.self, FeeCampaign.self, Payment.self, Expense.self], inMemory: true)
}
