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

    private let categories = ["Uniforms", "Tournaments", "Facilities", "Equipment", "Other"]

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
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || Decimal(string: amountText) == nil)
                }
            }
            .onChange(of: selectedPhoto) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        receiptImageData = data
                    }
                }
            }
        }
    }

    private func save() {
        guard let amount = Decimal(string: amountText) else { return }
        let expense = Expense(title: title, category: category, amount: amount, date: date, note: note, receiptImageData: receiptImageData)
        context.insert(expense)
        try? context.save()
        dismiss()
    }
}

#Preview {
    NewExpenseView()
        .modelContainer(for: [FamilyMember.self, FeeCampaign.self, Payment.self, Expense.self], inMemory: true)
}
