//
//  RootView.swift
//  dev1
//

import SwiftUI

/// Decides what the user sees at launch: first-run setup, the lock screen, or
/// the app itself.
struct RootView: View {
    @AppStorage(PreferenceKey.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @Environment(\.scenePhase) private var scenePhase
    @State private var appLock = AppLock()

    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView()
            } else if appLock.isLocked {
                LockScreenView(appLock: appLock)
            } else {
                RootTabView()
            }
        }
        .environment(appLock)
        .onAppear {
            // Lock on cold launch so the app doesn't open straight into the
            // ledger after being force-quit.
            appLock.lockIfEnabled()
        }
        .onChange(of: scenePhase) { _, phase in
            // .inactive covers the app-switcher snapshot, not just background,
            // so the balances aren't visible in the multitasking preview.
            if phase != .active {
                appLock.lockIfEnabled()
            }
        }
    }
}
