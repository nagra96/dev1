//
//  DataExportTests.swift
//  dev1Tests
//

import Foundation
import Testing
@testable import dev1

struct DataExportTests {
    @Test func balancesCSVHasHeaderAndOneRowPerFamily() {
        let a = FamilyMember(parentName: "Chen, Maria", playerName: "Ella", email: "m@example.com")
        let b = FamilyMember(parentName: "Ortiz", playerName: "Sam", email: "d@example.com")

        let csv = DataExport.balancesCSV(families: [a, b])
        let lines = csv.split(separator: "\n", omittingEmptySubsequences: false)

        #expect(lines.count == 3)
        #expect(lines[0].contains("Parent"))
    }

    /// A parent name containing a comma is completely ordinary and would shift
    /// every following column if it weren't quoted.
    @Test func commaInFieldIsQuoted() {
        let family = FamilyMember(parentName: "Chen, Maria", playerName: "Ella")
        let csv = DataExport.balancesCSV(families: [family])

        #expect(csv.contains("\"Chen, Maria\""))
    }

    /// Quotes inside a field must be doubled per RFC 4180, otherwise the field
    /// terminates early and the row is corrupt.
    @Test func quoteInFieldIsEscaped() {
        let family = FamilyMember(parentName: "Bob \"Coach\" Smith", playerName: "Jo")
        let csv = DataExport.balancesCSV(families: [family])

        #expect(csv.contains("\"Bob \"\"Coach\"\" Smith\""))
    }

    @Test func expensesCSVIncludesReceiptFlag() {
        let withReceipt = Expense(title: "Uniforms", category: "Uniforms", amount: 100,
                                  receiptImageData: Data([0x01]))
        let without = Expense(title: "Field", category: "Facilities", amount: 50)

        let csv = DataExport.expensesCSV(expenses: [withReceipt, without])

        #expect(csv.contains("\"Yes\""))
        #expect(csv.contains("\"No\""))
    }

    @Test func emptyCollectionsStillProduceAHeader() {
        #expect(DataExport.balancesCSV(families: []).contains("Parent"))
        #expect(DataExport.expensesCSV(expenses: []).contains("Category"))
        #expect(DataExport.paymentsCSV(campaigns: []).contains("Campaign"))
    }
}

struct TeamProfileTests {
    @Test func displayTitleFallsBackWhenNameIsEmpty() {
        let profile = TeamProfile(teamName: "")
        #expect(profile.displayTitle == "My Team")
    }

    @Test func subtitleJoinsOnlyNonEmptyParts() {
        let full = TeamProfile(teamName: "Rovers", organization: "Riverside YSC", seasonName: "Spring 2026")
        #expect(full.displaySubtitle == "Riverside YSC \u{00B7} Spring 2026")

        let partial = TeamProfile(teamName: "Rovers", organization: "", seasonName: "Spring 2026")
        #expect(partial.displaySubtitle == "Spring 2026")

        let none = TeamProfile(teamName: "Rovers")
        #expect(none.displaySubtitle.isEmpty)
    }
}
