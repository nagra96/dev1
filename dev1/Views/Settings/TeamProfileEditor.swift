//
//  TeamProfileEditor.swift
//  dev1
//

import SwiftUI

struct TeamProfileEditor: View {
    @Bindable var profile: TeamProfile
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var saveError: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Space.lg) {
                    LabeledField(title: "Team name", text: $profile.teamName, placeholder: "Riverside U12 Rovers")
                    LabeledField(title: "Club or organization", text: $profile.organization, placeholder: "Riverside Youth Soccer", optional: true)

                    VStack(alignment: .leading, spacing: Theme.Space.sm) {
                        Text("Sport")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Theme.inkSecondary)
                        Picker("Sport", selection: $profile.sport) {
                            ForEach(TeamProfile.sports, id: \.self) { Text($0).tag($0) }
                        }
                        .pickerStyle(.menu)
                        .tint(Theme.accent)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(Theme.Space.md)
                        .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.Radius.control, style: .continuous))
                    }

                    LabeledField(title: "Season", text: $profile.seasonName, placeholder: "Spring 2026", optional: true)

                    Divider().padding(.vertical, Theme.Space.xs)

                    LabeledField(title: "Treasurer name", text: $profile.treasurerName, placeholder: "Alex Morgan", optional: true)
                    LabeledField(title: "Treasurer email", text: $profile.treasurerEmail, placeholder: "alex@example.com", optional: true, keyboard: .emailAddress)
                }
                .padding(Theme.Space.xl)
            }
            .background(Theme.plane)
            .navigationTitle("Team Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        // Drop in-flight edits: @Bindable writes straight to the
                        // model, so cancelling has to roll the context back.
                        context.rollback()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(profile.teamName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .alert("Couldn\u{2019}t Save", isPresented: .constant(saveError != nil), presenting: saveError) { _ in
                Button("OK") { saveError = nil }
            } message: { message in
                Text(message)
            }
        }
    }

    private func save() {
        profile.teamName = profile.teamName.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.organization = profile.organization.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.seasonName = profile.seasonName.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.treasurerName = profile.treasurerName.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.treasurerEmail = profile.treasurerEmail.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            try context.save()
            dismiss()
        } catch {
            context.rollback()
            saveError = error.localizedDescription
        }
    }
}
