//
//  NewExpenseView.swift
//  dev1
//

import SwiftUI
import SwiftData
import PhotosUI
import UIKit

struct NewExpenseView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var category = "Uniforms"
    @State private var amountText = ""
    @State private var date = Date.now
    @State private var note = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var receiptImageData: Data?
    @State private var validationMessage: String?
    @State private var saveErrorMessage: String?

    private let categories = ["Uniforms", "Tournaments", "Facilities", "Equipment", "Other"]

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Expense") {
                    TextField("Title", text: $title)
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { Text($0) }
                    }
                    TextField("Amount", text: $amountText)
                        .keyboardType(.decimalPad)
                    if let validationMessage {
                        Text(validationMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Note", text: $note, axis: .vertical)
                }

                Section("Receipt") {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        if let receiptImageData, let uiImage = UIImage(data: receiptImageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 160)
                                .accessibilityLabel("Receipt photo attached")
                        } else {
                            Label("Attach Receipt Photo", systemImage: "camera")
                        }
                    }
                }
            }
            .navigationTitle("New Expense")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(trimmedTitle.isEmpty)
                }
            }
            .onChange(of: selectedPhoto) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        receiptImageData = data
                    }
                }
            }
            .alert("Couldn\u{2019}t Save Expense", isPresented: .constant(saveErrorMessage != nil), presenting: saveErrorMessage) { _ in
                Button("OK") { saveErrorMessage = nil }
            } message: { message in
                Text(message)
            }
        }
    }

    private func save() {
        switch CurrencyInput.parse(amountText) {
        case .failure(let error):
            validationMessage = error.errorDescription
            return
        case .success(let amount):
            validationMessage = nil

            let expense = Expense(
                title: trimmedTitle,
                category: category,
                amount: amount,
                date: date,
                note: note.trimmingCharacters(in: .whitespacesAndNewlines),
                receiptImageData: receiptImageData
            )
            context.insert(expense)

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
    NewExpenseView()
        .modelContainer(for: [TeamProfile.self, FamilyMember.self, FeeCampaign.self, Payment.self, Expense.self], inMemory: true)
}
