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
        PreferenceDefault.registerAll()
        do {
            container = try ModelContainer(
                for: TeamProfile.self, FamilyMember.self, FeeCampaign.self, Payment.self, Expense.self
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}
