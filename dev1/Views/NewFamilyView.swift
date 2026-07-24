//
//  NewFamilyView.swift
//  dev1
//

import SwiftUI
import SwiftData

struct NewFamilyView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var parentName = ""
    @State private var playerName = ""
    @State private var email = ""
    @State private var phone = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Parent/Guardian Name", text: $parentName)
                TextField("Player Name", text: $playerName)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                TextField("Phone", text: $phone)
                    .keyboardType(.phonePad)
            }
            .navigationTitle("Add Family")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(parentName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let family = FamilyMember(parentName: parentName, playerName: playerName, email: email, phone: phone)
        context.insert(family)
        try? context.save()
        dismiss()
    }
}

#Preview {
    NewFamilyView()
        .modelContainer(for: [FamilyMember.self, FeeCampaign.self, Payment.self, Expense.self], inMemory: true)
}
