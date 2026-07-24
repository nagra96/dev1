//
//  ModelTests.swift
//  dev1Tests
//

import Testing
import SwiftData
@testable import dev1

@MainActor
struct ModelTests {
    private func makeContext() throws -> ModelContext {
        let schema = Schema([FamilyMember.self, FeeCampaign.self, Payment.self, Expense.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        return ModelContext(container)
    }

    @Test func campaignTotalsReflectPayments() throws {
        let context = try makeContext()

        let campaign = FeeCampaign(title: "Uniform Fee", amount: 100, dueDate: .now)
        let familyA = FamilyMember(parentName: "A", playerName: "A Jr.")
        let familyB = FamilyMember(parentName: "B", playerName: "B Jr.")
        context.insert(campaign)
        context.insert(familyA)
        context.insert(familyB)

        let paymentA = Payment(campaign: campaign, family: familyA, amountDue: 100)
        paymentA.recordPayment(amount: 100)
        let paymentB = Payment(campaign: campaign, family: familyB, amountDue: 100)
        context.insert(paymentA)
        context.insert(paymentB)

        #expect(campaign.totalExpected == 200)
        #expect(campaign.totalCollected == 100)
        #expect(campaign.unpaidCount == 1)
    }

    @Test func partialPaymentUpdatesStatusAndBalance() throws {
        let context = try makeContext()
        let campaign = FeeCampaign(title: "Tournament", amount: 75, dueDate: .now)
        let family = FamilyMember(parentName: "Chen", playerName: "Ella")
        context.insert(campaign)
        context.insert(family)

        let payment = Payment(campaign: campaign, family: family, amountDue: 75)
        context.insert(payment)

        payment.recordPayment(amount: 25)
        #expect(payment.status == .partial)
        #expect(payment.balanceRemaining == 50)

        payment.recordPayment(amount: 50)
        #expect(payment.status == .paid)
        #expect(payment.balanceRemaining == 0)
    }

    @Test func familyBalancesAggregateAcrossCampaigns() throws {
        let context = try makeContext()
        let uniforms = FeeCampaign(title: "Uniforms", amount: 100, dueDate: .now)
        let tournament = FeeCampaign(title: "Tournament", amount: 50, dueDate: .now)
        let family = FamilyMember(parentName: "Ortiz", playerName: "Sam")
        context.insert(uniforms)
        context.insert(tournament)
        context.insert(family)

        let uniformPayment = Payment(campaign: uniforms, family: family, amountDue: 100)
        uniformPayment.recordPayment(amount: 100)
        let tournamentPayment = Payment(campaign: tournament, family: family, amountDue: 50)
        context.insert(uniformPayment)
        context.insert(tournamentPayment)

        #expect(family.totalPaid == 100)
        #expect(family.totalOwed == 50)
    }

    @Test func overpaymentNeverProducesNegativeBalance() throws {
        let context = try makeContext()
        let campaign = FeeCampaign(title: "Uniforms", amount: 100, dueDate: .now)
        let family = FamilyMember(parentName: "Blake", playerName: "Max")
        context.insert(campaign)
        context.insert(family)

        let payment = Payment(campaign: campaign, family: family, amountDue: 100)
        context.insert(payment)

        payment.recordPayment(amount: 150)
        #expect(payment.balanceRemaining == 0)
        #expect(payment.status == .paid)
    }
}
