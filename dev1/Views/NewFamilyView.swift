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
    @State private var emailWarning: String?
    @State private var saveErrorMessage: String?

    private var trimmedParentName: String {
        parentName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isEmailPlausible: Bool {
        trimmedEmail.isEmpty || (trimmedEmail.contains("@") && trimmedEmail.contains("."))
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Parent/Guardian Name", text: $parentName)
                    .accessibilityIdentifier("parentNameField")
                TextField("Player Name", text: $playerName)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                if let emailWarning {
                    Text(emailWarning)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
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
                        .disabled(trimmedParentName.isEmpty)
                }
            }
            .alert("Couldn\u{2019}t Save Family", isPresented: .constant(saveErrorMessage != nil), presenting: saveErrorMessage) { _ in
                Button("OK") { saveErrorMessage = nil }
            } message: { message in
                Text(message)
            }
        }
    }

    private func save() {
        guard isEmailPlausible else {
            emailWarning = "That doesn\u{2019}t look like a valid email address."
            return
        }
        emailWarning = nil

        let family = FamilyMember(
            parentName: trimmedParentName,
            playerName: playerName.trimmingCharacters(in: .whitespacesAndNewlines),
            email: trimmedEmail,
            phone: phone.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        context.insert(family)

        do {
            try context.save()
            dismiss()
        } catch {
            context.rollback()
            saveErrorMessage = error.localizedDescription
        }
    }
}

#Preview {
    NewFamilyView()
        .modelContainer(for: [TeamProfile.self, FamilyMember.self, FeeCampaign.self, Payment.self, Expense.self], inMemory: true)
}
