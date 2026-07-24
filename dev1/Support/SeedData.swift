//
//  SeedData.swift
//  dev1
//

import Foundation
import SwiftData
import os

enum SeedData {
    private static let logger = Logger(subsystem: "com.teamtreasury.dev1", category: "SeedData")

    @MainActor
    static func seedIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<FamilyMember>()
        let existingCount: Int
        do {
            existingCount = try context.fetchCount(descriptor)
        } catch {
            logger.error("Failed to check for existing data before seeding: \(error.localizedDescription)")
            return
        }
        guard existingCount == 0 else { return }

        let families = [
            FamilyMember(parentName: "Maria Chen", playerName: "Ella Chen", email: "maria@example.com", phone: "555-0101"),
            FamilyMember(parentName: "David Ortiz", playerName: "Sam Ortiz", email: "david@example.com", phone: "555-0102"),
            FamilyMember(parentName: "Priya Patel", playerName: "Aria Patel", email: "priya@example.com", phone: "555-0103"),
            FamilyMember(parentName: "Jordan Blake", playerName: "Max Blake", email: "jordan@example.com", phone: "555-0104")
        ]
        families.forEach { context.insert($0) }

        let calendar = Calendar.current
        let uniformCampaign = FeeCampaign(
            title: "Uniform Fee",
            amount: 150,
            dueDate: calendar.date(byAdding: .day, value: 14, to: .now) ?? .now,
            notes: "Covers jersey, shorts, and socks. Order placed with TeamSports Co."
        )
        let tournamentCampaign = FeeCampaign(
            title: "Spring Tournament",
            amount: 75,
            dueDate: calendar.date(byAdding: .day, value: 30, to: .now) ?? .now,
            notes: "Entry fee for the regional tournament in May."
        )
        context.insert(uniformCampaign)
        context.insert(tournamentCampaign)

        for (index, family) in families.enumerated() {
            let uniformPayment = Payment(campaign: uniformCampaign, family: family, amountDue: uniformCampaign.amount)
            if index < 2 {
                uniformPayment.recordPayment(amount: uniformCampaign.amount)
            }
            context.insert(uniformPayment)

            let tournamentPayment = Payment(campaign: tournamentCampaign, family: family, amountDue: tournamentCampaign.amount)
            if index == 0 {
                tournamentPayment.recordPayment(amount: tournamentCampaign.amount)
            }
            context.insert(tournamentPayment)
        }

        let expenses = [
            Expense(title: "Uniform Order", category: "Uniforms", amount: 480, date: calendar.date(byAdding: .day, value: -10, to: .now) ?? .now, note: "12 jerseys from TeamSports Co."),
            Expense(title: "Field Rental", category: "Facilities", amount: 220, date: calendar.date(byAdding: .day, value: -5, to: .now) ?? .now, note: "March practice sessions"),
            Expense(title: "Tournament Registration", category: "Tournaments", amount: 300, date: calendar.date(byAdding: .day, value: -2, to: .now) ?? .now, note: "Spring regional entry")
        ]
        expenses.forEach { context.insert($0) }

        do {
            try context.save()
        } catch {
            logger.error("Failed to save seed data: \(error.localizedDescription)")
        }
    }
}
