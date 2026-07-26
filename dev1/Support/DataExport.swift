//
//  DataExport.swift
//  dev1
//

import Foundation
import SwiftData
import os

/// CSV export. Real data portability matters more than usual here: a treasurer
/// hands the books to next season's volunteer, and a club board may want the
/// numbers in a spreadsheet. Since the store is device-local with no backup,
/// this is also the only way to get data off the phone.
enum DataExport {
    private static let logger = Logger(subsystem: "com.teamtreasury.dev1", category: "DataExport")

    /// Escapes a field for RFC 4180: wrap in quotes and double any inner quote.
    /// Names and notes routinely contain commas, so this is not optional.
    private static func escape(_ field: String) -> String {
        let cleaned = field.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(cleaned)\""
    }

    private static func row(_ fields: [String]) -> String {
        fields.map(escape).joined(separator: ",")
    }

    private static var isoDate: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter
    }

    private static func amount(_ value: Decimal) -> String {
        NSDecimalNumber(decimal: value).stringValue
    }

    static func balancesCSV(families: [FamilyMember]) -> String {
        var lines = [row(["Parent", "Player", "Email", "Phone", "Total Paid", "Total Owed"])]
        for family in families.sorted(by: { $0.parentName < $1.parentName }) {
            lines.append(row([
                family.parentName,
                family.playerName,
                family.email,
                family.phone,
                amount(family.totalPaid),
                amount(family.totalOwed)
            ]))
        }
        return lines.joined(separator: "\n")
    }

    static func paymentsCSV(campaigns: [FeeCampaign]) -> String {
        var lines = [row(["Campaign", "Due Date", "Parent", "Player", "Amount Due", "Amount Paid", "Status", "Paid Date"])]
        for campaign in campaigns.sorted(by: { $0.dueDate < $1.dueDate }) {
            for payment in campaign.payments.sorted(by: { ($0.family?.parentName ?? "") < ($1.family?.parentName ?? "") }) {
                lines.append(row([
                    campaign.title,
                    isoDate.string(from: campaign.dueDate),
                    payment.family?.parentName ?? "",
                    payment.family?.playerName ?? "",
                    amount(payment.amountDue),
                    amount(payment.amountPaid),
                    payment.status.rawValue,
                    payment.paidDate.map { isoDate.string(from: $0) } ?? ""
                ]))
            }
        }
        return lines.joined(separator: "\n")
    }

    static func expensesCSV(expenses: [Expense]) -> String {
        var lines = [row(["Date", "Title", "Category", "Amount", "Note", "Has Receipt"])]
        for expense in expenses.sorted(by: { $0.date < $1.date }) {
            lines.append(row([
                isoDate.string(from: expense.date),
                expense.title,
                expense.category,
                amount(expense.amount),
                expense.note,
                expense.receiptImageData == nil ? "No" : "Yes"
            ]))
        }
        return lines.joined(separator: "\n")
    }

    /// Writes a CSV to a temp file so it can be shared as a real `.csv`
    /// document (opens in Numbers/Excel) rather than as a wall of text.
    static func writeTemporaryFile(named name: String, contents: String) -> URL? {
        let safeName = name.replacingOccurrences(of: "/", with: "-")
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(safeName).csv")
        do {
            try contents.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            logger.error("Failed to write export file: \(error.localizedDescription)")
            return nil
        }
    }
}

/// Deletes every record. Used by Settings → Erase All Data.
enum DataReset {
    private static let logger = Logger(subsystem: "com.teamtreasury.dev1", category: "DataReset")

    @MainActor
    static func eraseAll(context: ModelContext) -> Bool {
        do {
            // Payments are cascade-deleted from both sides, but deleting them
            // explicitly first keeps the operation independent of relationship
            // delete-rule ordering.
            try context.delete(model: Payment.self)
            try context.delete(model: Expense.self)
            try context.delete(model: FeeCampaign.self)
            try context.delete(model: FamilyMember.self)
            try context.save()
            return true
        } catch {
            context.rollback()
            logger.error("Failed to erase data: \(error.localizedDescription)")
            return false
        }
    }
}
