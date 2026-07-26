//
//  ExpensesListView.swift
//  dev1
//

import SwiftUI
import SwiftData
import UIKit
import os

struct ExpensesListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @State private var isPresentingNewExpense = false

    private static let logger = Logger(subsystem: "com.teamtreasury.dev1", category: "ExpensesListView")

    private var totalExpenses: Decimal {
        expenses.reduce(Decimal(0)) { $0 + $1.amount }
    }

    private var expensesByCategory: [CategoryTotal] {
        Dictionary(grouping: expenses, by: \.category)
            .map { CategoryTotal(category: $0.key, total: $0.value.reduce(Decimal(0)) { $0 + $1.amount }) }
            .sorted { $0.total > $1.total }
    }

    var body: some View {
        Group {
            if expenses.isEmpty {
                EmptyStateView(
                    icon: "receipt.fill",
                    title: "No expenses logged",
                    message: "Track what the team spends \u{2014} uniforms, field rentals, tournament fees \u{2014} and snap a receipt while you\u{2019}re at it.",
                    actionTitle: "Add Expense"
                ) {
                    isPresentingNewExpense = true
                }
            } else {
                List {
                    Section {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Season spend")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Theme.inkSecondary)
                            Text(totalExpenses.currencyString)
                                .font(Theme.figure(30, weight: .bold))
                                .foregroundStyle(Theme.inkPrimary)
                            Text("\(expenses.count) \(expenses.count == 1 ? "entry" : "entries") across \(expensesByCategory.count) \(expensesByCategory.count == 1 ? "category" : "categories")")
                                .font(.system(size: 11))
                                .foregroundStyle(Theme.inkMuted)
                        }
                        .card()
                        .plainRow(top: Theme.Space.md)

                        ExpenseBreakdownChart(totals: expensesByCategory)
                            .plainRow()
                    }

                    Section {
                        ForEach(expenses) { expense in
                            ExpenseRow(expense: expense)
                                .plainRow()
                        }
                        .onDelete(perform: deleteExpenses)
                    } header: {
                        Text("All expenses")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.inkSecondary)
                            .textCase(nil)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .background(Theme.plane)
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
        do {
            try context.save()
        } catch {
            context.rollback()
            Self.logger.error("Failed to delete expense: \(error.localizedDescription)")
        }
    }
}

extension View {
    /// Strips the system list chrome so a card can sit directly on the plane.
    func plainRow(top: CGFloat = Theme.Space.sm) -> some View {
        self
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: top, leading: Theme.Space.lg,
                                      bottom: Theme.Space.sm, trailing: Theme.Space.lg))
    }
}

/// Category glyphs. Purely a visual anchor — the category name is always
/// shown beside it, so the icon never carries meaning on its own.
enum ExpenseCategoryStyle {
    static func icon(for category: String) -> String {
        switch category {
        case "Uniforms": return "tshirt.fill"
        case "Tournaments": return "trophy.fill"
        case "Facilities": return "sportscourt.fill"
        case "Equipment": return "bag.fill"
        default: return "tag.fill"
        }
    }
}

private struct ExpenseRow: View {
    let expense: Expense

    var body: some View {
        HStack(spacing: Theme.Space.md) {
            if let data = expense.receiptImageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .strokeBorder(Theme.hairline, lineWidth: 0.5)
                    )
            } else {
                Image(systemName: ExpenseCategoryStyle.icon(for: expense.category))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.accent)
                    .frame(width: 44, height: 44)
                    .background(Theme.accentMuted, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(expense.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.inkPrimary)
                HStack(spacing: Theme.Space.xs) {
                    Text(expense.category)
                    Text("\u{00B7}")
                    Text(expense.date.formatted(date: .abbreviated, time: .omitted))
                }
                .font(.system(size: 12))
                .foregroundStyle(Theme.inkMuted)
            }

            Spacer(minLength: Theme.Space.sm)

            Text(expense.amount.currencyString)
                .font(Theme.figure(16, weight: .bold))
                .foregroundStyle(Theme.inkPrimary)
        }
        .card()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(expense.title), \(expense.category)")
        .accessibilityValue("\(expense.amount.currencyString) on \(expense.date.formatted(date: .abbreviated, time: .omitted))")
    }
}

#Preview {
    NavigationStack { ExpensesListView() }
        .modelContainer(for: [FamilyMember.self, FeeCampaign.self, Payment.self, Expense.self], inMemory: true)
}
