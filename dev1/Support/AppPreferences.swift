//
//  AppPreferences.swift
//  dev1
//

import Foundation

/// Keys for lightweight UI preferences. These are genuine preferences (they
/// change how the app behaves for this user on this device), not domain data —
/// team and season details live in `TeamProfile` in SwiftData instead.
enum PreferenceKey {
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    static let passFeeToFamilyDefault = "passFeeToFamilyDefault"
    static let reminderLeadDays = "reminderLeadDays"
    static let appLockEnabled = "appLockEnabled"
}

enum PreferenceDefault {
    static func registerAll() {
        UserDefaults.standard.register(defaults: [
            PreferenceKey.passFeeToFamilyDefault: true,
            PreferenceKey.reminderLeadDays: 3
        ])
    }
}
