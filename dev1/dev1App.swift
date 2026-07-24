//
//  dev1App.swift
//  dev1
//
//  Created by RAJVIR KAUR on 2025-07-19.
//

import SwiftUI
import SwiftData

@main
struct dev1App: App {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: FamilyMember.self, FeeCampaign.self, Payment.self, Expense.self)
            SeedData.seedIfNeeded(context: container.mainContext)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(container)
    }
}
