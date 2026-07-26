//
//  RootTabView.swift
//  dev1
//

import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            NavigationStack { DashboardView() }
                .tabItem { Label("Dashboard", systemImage: "chart.pie.fill") }

            NavigationStack { CampaignsListView() }
                .tabItem { Label("Campaigns", systemImage: "dollarsign.circle.fill") }

            NavigationStack { FamiliesListView() }
                .tabItem { Label("Families", systemImage: "person.2.fill") }

            NavigationStack { ExpensesListView() }
                .tabItem { Label("Expenses", systemImage: "receipt.fill") }
        }
        .tint(Theme.accent)
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: [FamilyMember.self, FeeCampaign.self, Payment.self, Expense.self], inMemory: true)
}
