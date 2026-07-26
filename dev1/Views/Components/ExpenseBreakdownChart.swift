//
//  ExpenseBreakdownChart.swift
//  dev1
//

import Foundation
import SwiftUI
import Charts

struct CategoryTotal: Identifiable, Equatable {
    let category: String
    let total: Decimal
    var id: String { category }

    var doubleValue: Double {
        Double(truncating: NSDecimalNumber(decimal: total))
    }
}

/// Spend by category, as horizontal bars.
///
/// Design notes, each deliberate:
/// - **One color for every bar.** Expense categories are nominal — "Uniforms"
///   is not greater than "Facilities" — so a darker-where-bigger ramp would
///   double-encode bar length as hue and burn the only free channel on
///   information the length already shows. Single series, single hue.
/// - **Horizontal**, because the category names are words, not dates.
/// - **No legend.** One series means the title already says what is plotted; a
///   one-swatch legend would just restate it.
/// - **Values at the tip**, in ink rather than the bar color, so the numbers
///   stay legible and identity comes from the mark beside them.
struct ExpenseBreakdownChart: View {
    let totals: [CategoryTotal]

    /// Height grows with the row count so the category labels are always inside
    /// the container — a fixed height would push the axis band into a nested
    /// scroll view.
    private var chartHeight: CGFloat {
        CGFloat(max(totals.count, 1)) * 34 + 8
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Space.md) {
            Text("Where the money went")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.inkPrimary)

            if totals.isEmpty {
                Text("Log an expense to see the season breakdown.")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.inkMuted)
                    .padding(.vertical, Theme.Space.sm)
            } else {
                Chart(totals) { entry in
                    BarMark(
                        x: .value("Amount", entry.doubleValue),
                        y: .value("Category", entry.category),
                        height: .fixed(18)
                    )
                    .foregroundStyle(Theme.accent)
                    .cornerRadius(Theme.Radius.mark)
                    .annotation(position: .trailing, alignment: .leading) {
                        Text(entry.total.currencyString)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Theme.inkSecondary)
                    }
                }
                .chartXAxis(.hidden)
                .chartYAxis {
                    AxisMarks(preset: .aligned, position: .leading) { _ in
                        AxisValueLabel()
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.inkSecondary)
                    }
                }
                // Headroom so the trailing value labels are never clipped.
                .chartXScale(domain: 0...(maxValue * 1.28))
                .frame(height: chartHeight)
                .accessibilityLabel("Expenses by category")
            }
        }
        .card()
    }

    private var maxValue: Double {
        max(totals.map(\.doubleValue).max() ?? 1, 1)
    }
}

#Preview {
    ExpenseBreakdownChart(totals: [
        CategoryTotal(category: "Uniforms", total: 480),
        CategoryTotal(category: "Tournaments", total: 300),
        CategoryTotal(category: "Facilities", total: 220)
    ])
    .padding()
    .background(Theme.plane)
}
