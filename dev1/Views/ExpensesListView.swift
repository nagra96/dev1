//
//  ExpensesListView.swift
//  dev1
//

import SwiftUI
import SwiftData
import UIKit

struct ExpensesListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @State private var isPresentingNewExpense = false

    private var totalExpenses: Decimal {
        expenses.reduce(Decimal(0)) { $0 + $1.amount }
    }

    private var expensesByCategory: [CategoryTotal] {
        Dictionary(grouping: expenses, by: \.category)
            .map { CategoryTotal(category: $0.key, total: $0.value.reduce(Decimal(0)) { $0 + $1.amount }) }
            .sorted { $0.total > $1.total }
    }

    var body: some View {
        List {
            Section("Season Budget") {
                LabeledContent("Total Expenses", value: totalExpenses.currencyString)
                ForEach(expensesByCategory) { entry in
                    LabeledContent(entry.category, value: entry.total.currencyString)
                }
            }

            Section("All Expenses") {
                if expenses.isEmpty {
                    Text("No expenses logged yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(expenses) { expense in
                        ExpenseRow(expense: expense)
                    }
                    .onDelete(perform: deleteExpenses)
                }
            }
        }
        .navigationTitle("Expenses")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isPresentingNewExpense = true
                } label: {
                    Label("Add Expense", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isPresentingNewExpense) {
            NewExpenseView()
        }
    }

    private func deleteExpenses(at offsets: IndexSet) {
        for index in offsets {
            context.delete(expenses[index])
        }
    }
}

private struct CategoryTotal: Identifiable {
    let category: String
    let total: Decimal
    var id: String { category }
}

private struct ExpenseRow: View {
    let expense: Expense

    var body: some View {
        HStack(spacing: 12) {
            if let data = expense.receiptImageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.secondary.opacity(0.15))
                    .frame(width: 40, height: 40)
                    .overlay(Image(systemName: "receipt").foregroundStyle(.secondary))
            }

            VStack(alignment: .leading) {
                Text(expense.title).font(.headline)
                Text(expense.category).font(.caption).foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(expense.amount.currencyString).fontWeight(.semibold)
                Text(expense.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack { ExpensesListView() }
        .modelContainer(for: [FamilyMember.self, FeeCampaign.self, Payment.self, Expense.self], inMemory: true)
}
